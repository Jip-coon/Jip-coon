//
//  AllQuestViewController.swift
//  Feature
//
//  Created by 예슬 on 1/18/26.
//

import Combine
import UI
import UIKit

public class AllQuestViewController: UIViewController{
    private let viewModel: AllQuestViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let segmentControl = UnderlineSegmentControl(
        titles: ["오늘", "예정", "지난"]
    )
    
    private let filterButton = FilterButtonView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "등록된 퀘스트가 없습니다\n퀘스트를 추가해 보세요"
        label.numberOfLines = 2
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - init
    
    public init(viewModel: AllQuestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupConstraints()
        bindViewModel()
        setupNotificationCenter()
        setupSegmentedControl()
        setupFilterButton()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { [weak self] in
            await self?.viewModel.fetchAllQuests()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundWhite
        navigationItem.title = "퀘스트"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupConstraints() {
        self.view.addSubview(segmentControl)
        self.view.addSubview(filterButton)
        self.view.addSubview(tableView)
        self.view.addSubview(emptyLabel)
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            segmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            segmentControl.heightAnchor
                .constraint(equalToConstant: 30),
            
            filterButton.topAnchor
                .constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            filterButton.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            filterButton.heightAnchor
                .constraint(equalToConstant: 35),
            
            tableView.topAnchor
                .constraint(equalTo: filterButton.bottomAnchor, constant: 30),
            tableView.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyLabel.centerXAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLabel.centerYAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            AllQuestTableViewCell.self,
            forCellReuseIdentifier: AllQuestTableViewCell.identifier
        )
    }
    
    /// 퀘스트 생성 알림 구독
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(questCreated),
            name: NSNotification.Name("QuestCreated"),
            object: nil
        )
    }
    
    @objc private func questCreated() {
        Task { [weak self] in
            await self?.viewModel.fetchAllQuests()
        }
    }
    
    /// 오늘, 예정, 지난 탭 관리
    private func setupSegmentedControl() {
        segmentControl.onIndexChanged = { [weak self] index in
            guard let self else { return }
            
            switch index {
                case 0:
                    self.viewModel.selectedSegment = .today
                case 1:
                    self.viewModel.selectedSegment = .upcoming
                case 2:
                    self.viewModel.selectedSegment = .past
                default:
                    break
            }
        }
    }
    
    private func setupFilterButton() {
        filterButton.onFilterChanged = { [weak self] options in
            self?.viewModel.selectedStatusOptions = options
        }
    }
    
    // MARK: - Data Binding
    
    private func bindViewModel() {
        // 퀘스트가 변경 됐을 경우
        viewModel.$currentQuests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateEmptyState()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    /// 퀘스트 없을 경우
    private func updateEmptyState() {
        let isEmpty = viewModel.currentQuests.isEmpty
        
        tableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
}

// MARK: - TableView Delegate

extension AllQuestViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentQuests.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Cell ContainerView Height = 75, Padding = 15
        return 90
    }
    
}

// MARK: - TableView DataSource

extension AllQuestViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AllQuestTableViewCell.identifier) as? AllQuestTableViewCell
        else {
            fatalError("Could not dequeue AllQuestTableViewCell")
        }
        
        cell.configureUI(
            with: viewModel.currentQuests[indexPath.row],
            members: viewModel.familyMembers
        )
        
        return cell
    }
}

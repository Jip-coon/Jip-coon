//
//  AllQuestViewController.swift
//  Feature
//
//  Created by 예슬 on 1/18/26.
//

import Combine
import UI
import UIKit

public class AllQuestViewController: UIViewController {
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
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "퀘스트가 없습니다"
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
        viewModel.$sectionedQuests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateEmptyState()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    /// 퀘스트 없을 경우
    private func updateEmptyState() {
        let isEmpty = viewModel.sectionedQuests.isEmpty
        
        tableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
}

// MARK: - TableView Delegate

extension AllQuestViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Cell ContainerView Height = 75, Padding = 15
        return 90
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quest = viewModel.sectionedQuests[indexPath.section].quests[indexPath.row]
        
        let questDetailViewController = QuestDetailViewController(
            quest: quest,
            questService: viewModel.questService,
            userService: viewModel.userService
        )
        
        navigationController?.pushViewController(questDetailViewController, animated: true)
    }
    
}

// MARK: - TableView DataSource

extension AllQuestViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionedQuests.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionedQuests[section].quests.count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if viewModel.selectedSegment == .today { return nil }

        let container = UIView()
        container.backgroundColor = .backgroundWhite

        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .textGray
        label.text = viewModel.sectionedQuests[section].date.mmDDe

        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: container.topAnchor)
        ])

        return container
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.selectedSegment == .today ? 0 : 27
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AllQuestTableViewCell.identifier) as? AllQuestTableViewCell
        else {
            fatalError("Could not dequeue AllQuestTableViewCell")
        }
        
        cell.configureUI(
            with: viewModel.sectionedQuests[indexPath.section].quests[indexPath.row],
            members: viewModel.familyMembers
        )
        
        return cell
    }
    
}

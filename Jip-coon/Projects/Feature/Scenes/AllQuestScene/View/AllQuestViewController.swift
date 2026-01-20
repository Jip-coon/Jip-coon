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
    
    public init(viewModel: AllQuestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupConstraints()
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
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
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
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    
    private func bindViewModel() {
        viewModel.$allQuests
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - TableView Delegate

extension AllQuestViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.allQuests.count
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
        
        cell.configureUI(with: viewModel.allQuests[indexPath.row], members: viewModel.familyMembers)
        
        return cell
    }
}

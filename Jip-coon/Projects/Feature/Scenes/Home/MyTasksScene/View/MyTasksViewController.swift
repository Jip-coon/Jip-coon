//
//  MyTasksViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/26/26.
//

import UIKit
import Core
import Combine
import UI

/// 나의 할일 목록을 표시하는 뷰 컨트롤러
public class MyTasksViewController: UIViewController {
    
    private let userService: UserServiceProtocol
    private let questService: QuestServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var myTasks: [Quest] = []
    private var familyMembers: [User] = []
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyIconView: UIImageView = {
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        iconView.image = UIImage(systemName: "archivebox", withConfiguration: config)
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "집안일이 없어요"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    
    public init(
        userService: UserServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.userService = userService
        self.questService = questService
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
        setupNotifications()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundWhite
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyIconView)
        emptyStateView.addSubview(emptyLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyIconView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyIconView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIconView.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 100),
            emptyIconView.widthAnchor.constraint(equalToConstant: 60),
            emptyIconView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyIconView.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            MyTasksTableViewCell.self,
            forCellReuseIdentifier: MyTasksTableViewCell.identifier
        )
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuestCreated),
            name: NSNotification.Name("QuestCreated"),
            object: nil
        )
    }
    
    @objc private func handleQuestCreated() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        Task {
            do {
                // 현재 사용자 정보 가져오기
                let currentUser = try await userService.getCurrentUser()
                guard let userId = currentUser?.id,
                      let familyId = currentUser?.familyId else {
                    print("현재 사용자 정보를 불러오기에 실패했습니다.")
                    return
                }
                
                // 나의 할일 가져오기 (assignedTo가 현재 사용자인 퀘스트)
                let familyQuests = try await questService.getFamilyQuests(familyId: familyId)
                let myQuests = familyQuests.filter { quest in
                    quest.assignedTo == userId && 
                    (quest.status == .pending || quest.status == .inProgress)
                }
                
                // 가족 구성원 정보 가져오기
                let family = try await userService.getFamilyMembers(familyId: familyId)
                
                await MainActor.run {
                    self.myTasks = myQuests
                    self.familyMembers = family
                    self.updateEmptyState()
                    self.tableView.reloadData()
                }
            } catch {
                print("데이터 로드 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 빈 상태 업데이트
    private func updateEmptyState() {
        let isEmpty = myTasks.isEmpty
        
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
    }
    
    // MARK: - Actions
    
    private func handleTaskTapped(_ quest: Quest) {
        let questDetailVC = QuestDetailViewController(
            quest: quest,
            questService: questService,
            userService: userService
        )
        
        // 네비게이션 컨트롤러가 없으면 모달로 표시
        let navController = UINavigationController(rootViewController: questDetailVC)
        
        // 닫기 버튼 추가
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissQuestDetail)
        )
        questDetailVC.navigationItem.leftBarButtonItem = closeButton
        
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func dismissQuestDetail() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension MyTasksViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let quest = myTasks[indexPath.row]
        handleTaskTapped(quest)
    }
}

// MARK: - UITableViewDataSource

extension MyTasksViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTasks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyTasksTableViewCell.identifier) as? MyTasksTableViewCell
        else {
            fatalError("Could not dequeue MyTasksTableViewCell")
        }
        
        let quest = myTasks[indexPath.row]
        cell.configure(with: quest, familyMembers: familyMembers)
        
        return cell
    }
}

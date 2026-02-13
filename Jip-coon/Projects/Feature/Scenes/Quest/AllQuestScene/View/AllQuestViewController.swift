//
//  AllQuestViewController.swift
//  Feature
//
//  Created by 예슬 on 1/18/26.
//

import Combine
import Core
import UI
import UIKit

class AllQuestViewController: UIViewController {
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
    
    init(viewModel: AllQuestViewModel) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupConstraints()
        bindViewModel()
        setupNotificationCenter()
        setupSegmentedControl()
        setupFilterButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            segmentControl.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
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
    
    /// 퀘스트 삭제
    private func performDelete(at indexPath: IndexPath, for quest: Quest, mode: DeleteMode) {
        let isLastItemInSection = viewModel.sectionedQuests[indexPath.section].quests.count == 1
        
        viewModel.removeQuestFromLocal(quest)
        
        tableView.performBatchUpdates({
            if isLastItemInSection {
                // 섹션의 마지막 아이템이었다면 섹션 자체를 삭제
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                // 섹션 내에 다른 아이템이 남아있다면 해당 로우만 삭제
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }, completion: { [weak self] _ in
            Task {
                await self?.viewModel.deleteQuest(quest, mode: mode)
            }
        })
    }
    
    /// 퀘스트 삭제 알림
    private func showDeleteOptionAlert(for quest: Quest, indexPath: IndexPath) {
        // 반복 퀘스트가 아닌 경우 (단일 일반 퀘스트)
        if quest.templateId == nil {
            let alert = UIAlertController(
                title: "퀘스트 삭제",
                message: "이 퀘스트를 삭제하시겠습니까?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                self?.performDelete(at: indexPath, for: quest, mode: .single)
            })
            present(alert, animated: true)
            return
        }
        
        // 반복 퀘스트인 경우
        let actionSheet = UIAlertController(
            title: "반복 퀘스트 삭제",
            message: "삭제 방식을 선택해주세요.",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "이 일정만 삭제", style: .default) { [weak self] _ in
            self?.performDelete(at: indexPath, for: quest, mode: .single)
        })
        
        actionSheet.addAction(UIAlertAction(title: "반복 일정 전체 삭제", style: .destructive) { [weak self] _ in
            self?.performDelete(at: indexPath, for: quest, mode: .all)
        })
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    /// 퀘스트 삭제 권한 없음 알림
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "권한 없음",
            message: "본인의 퀘스트또는 부모님만 삭제할 수 있습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegate

extension AllQuestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Cell ContainerView Height = 75, Padding = 15
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quest = viewModel.sectionedQuests[indexPath.section].quests[indexPath.row]
        
        let questDetailViewController = QuestDetailViewController(
            quest: quest,
            questService: viewModel.questService,
            userService: viewModel.userService
        )
        
        navigationController?.pushViewController(questDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let quest = self.viewModel.sectionedQuests[indexPath.section].quests[indexPath.row]
            
            // 권한 체크 로직 실행
            Task {
                if await self.viewModel.canDeleteQuest(quest) {
                    self.showDeleteOptionAlert(for: quest, indexPath: indexPath)
                } else {
                    self.showPermissionDeniedAlert()
                }
            }
            
            completion(true)
        }
        deleteAction.backgroundColor = .backgroundWhite
        deleteAction.image = UIImage(named: "deleteButton", in: uiBundle, compatibleWith: nil)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - TableView DataSource

extension AllQuestViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionedQuests.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionedQuests[section].quests.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.selectedSegment == .today ? 0 : 27
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AllQuestTableViewCell.identifier) as? AllQuestTableViewCell
        else {
            fatalError("Could not dequeue AllQuestTableViewCell")
        }
        
        cell.configureUI(
            with: viewModel.sectionedQuests[indexPath.section].quests[indexPath.row],
            members: viewModel.familyMembers,
            segment: viewModel.selectedSegment
        )
        
        return cell
    }
}

//
//  MainViewController.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import Combine
import Core
import UI
import UIKit

public class MainViewController: UIViewController {

    private let components = MainViewComponents()
    private lazy var layoutManager = MainViewLayout(components: components)
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCombineBindings()
        setupActions()
        viewModel.loadInitialData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.refreshData()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        components.updateShadowPaths()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.headerBeige
        layoutManager.setupViewHierarchy(in: view)
        layoutManager.setupConstraints(in: view)
        setupQuickActions()
    }

    private func setupActions() {
        components.notificationButton.addTarget(
            self, action: #selector(notificationButtonTapped), for: .touchUpInside)
    }

    // MARK: - 바인딩

    private func setupCombineBindings() {
        viewModel.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.components.userNameLabel.text = user.name
                self?.components.pointsLabel.text = "\(user.points)P"
            }
            .store(in: &cancellables)

        viewModel.$family
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] family in
                self?.components.familyNameLabel.text = family.name
            }
            .store(in: &cancellables)

        viewModel.$urgentQuests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quests in
                self?.components.setupUrgentTasks(with: quests) { quest in
                    self?.handleUrgentTaskTapped(quest)
                }
            }
            .store(in: &cancellables)

        viewModel.$urgentCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.components.urgentCountLabel.text = count
            }
            .store(in: &cancellables)

        viewModel.$myTasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.components.setupMyTasks(with: tasks) { task in
                    self?.handleMyTaskTapped(task)
                }
            }
            .store(in: &cancellables)

        viewModel.$weeklyStats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                let progress = stats.completionRate / 100.0
                self?.components.progressView.progress = Float(progress)
            }
            .store(in: &cancellables)

        viewModel.$progressText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.components.progressLabel.text = progress
            }
            .store(in: &cancellables)

        viewModel.$categoryStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.setupCategoryStats(stats)
            }
            .store(in: &cancellables)

        viewModel.$recentActivities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.components.setupRecentActivities(with: activities) { activity in
                    self?.handleRecentActivityTapped(activity)
                }
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.hideLoadingIndicator()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }

    private func setupQuickActions() {
        components.setupQuickActions { [weak self] action in
            self?.handleQuickActionTapped(action)
        }
    }

    @objc private func notificationButtonTapped() {
        // TODO: - 알림 화면으로 이동 구현
    }

    private func handleUrgentTaskTapped(_ quest: Quest) {
        let alert = createQuestActionAlert(for: quest)
        present(alert, animated: true)
    }

    private func markQuestAsCompleted(_ quest: Quest) {
        showCompletionAlert(for: quest)
        viewModel.refreshData()
    }

    private func showQuestDetails(_ quest: Quest) {
        // TODO: - 할 일 상세 화면으로 이동 구현
    }

    private func postponeQuest(_ quest: Quest) {
        showPostponeAlert(for: quest)
    }

    // MARK: - Helper Methods

    private func setupCategoryStats(_ stats: [CategoryStatistic]) {
        let categoryStats: [(QuestCategory, Int)] = stats.map { ($0.category, $0.count) }
        components.setupCategoryStatsIcons(with: categoryStats) { [weak self] category, count in
            self?.handleCategoryStatTapped(category, count: count)
        }
    }

    // MARK: - UI 상태 관리

    private func showLoadingIndicator() {
        // 로딩 인디케이터 구현 (향후 추가)
        DispatchQueue.main.async { [weak self] in
            self?.view.isUserInteractionEnabled = false
        }
    }

    private func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.view.isUserInteractionEnabled = true
        }
    }

    private func showErrorAlert(message: String) {
        showAlert(title: "오류", message: message)
    }

    // MARK: - Alert Factory Methods

    private func createQuestActionAlert(for quest: Quest) -> UIAlertController {
        let urgencyLevel = QuestUrgencyCalculator.determineUrgencyLevel(for: quest)

        let alert = UIAlertController(
            title: "\(quest.category.emoji) \(quest.title)",
            message: QuestUrgencyCalculator.getUrgentTaskMessage(for: quest, urgencyLevel: urgencyLevel),
            preferredStyle: .alert
        )

        addQuestActions(to: alert, for: quest, urgencyLevel: urgencyLevel)
        return alert
    }

    private func addQuestActions(
        to alert: UIAlertController, for quest: Quest, urgencyLevel: UrgencyLevel
    ) {
        // 완료 액션 (진행 중이거나 대기 중인 경우만)
        if quest.status == .inProgress || quest.status == .pending {
            alert.addAction(
                UIAlertAction(title: "완료", style: .default) { [weak self] _ in
                    self?.markQuestAsCompleted(quest)
                })
        }

        // 자세히 보기 액션
        alert.addAction(
            UIAlertAction(title: "자세히 보기", style: .default) { [weak self] _ in
                self?.showQuestDetails(quest)
            })

        // 연기 액션 (긴급하지 않은 경우만)
        if urgencyLevel != .critical {
            alert.addAction(
                UIAlertAction(title: "나중에 하기", style: .default) { [weak self] _ in
                    self?.postponeQuest(quest)
                })
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    }

    private func showCompletionAlert(for quest: Quest) {
        showAlert(
            title: "🎉 완료!",
            message: "'\(quest.title)'을(를) 완료했습니다!\n+\(quest.points) 포인트 획득"
        )
    }

    private func showPostponeAlert(for quest: Quest) {
        showAlert(
            title: "⏰ 연기됨",
            message: "'\(quest.title)'을(를) 나중으로 연기했습니다."
        )
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController {

    private func handleQuickActionTapped(_ action: QuickAction) {
        switch action.type {
            case .newQuest:
                navigationItem.backButtonTitle = ""
                let addQuestViewController = AddQuestViewController()
                navigationController?.pushViewController(addQuestViewController, animated: true)
                break
            case .search:
                // TODO: - 검색 화면으로 이동
                break
            case .invite:
                // TODO: - 초대 화면으로 이동
                break
            case .approval:
                // TODO: - 승인 대기 화면으로 이동
                break
        }
    }

    private func handleMyTaskTapped(_ quest: Quest) {
        // TODO: - 할일 상세 화면으로 이동
        let questDetailViewController = QuestDetailViewController(quest: quest)
        navigationItem.backButtonTitle = ""
        navigationController?.pushViewController(questDetailViewController, animated: true)
    }

    private func handleRecentActivityTapped(_ activity: RecentActivity) {
        // TODO: - 활동 상세 화면으로 이동
    }

    private func handleCategoryStatTapped(_ category: QuestCategory, count: Int) {
        // TODO: - 해당 카테고리 할일 목록 화면으로 이동
    }
}

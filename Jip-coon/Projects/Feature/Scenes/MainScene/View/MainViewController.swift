//
//  MainViewController.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import Core
import UI
import UIKit

public class MainViewController: UIViewController {

    private let components = MainViewComponents()  // UI 컴포넌트들
    private lazy var layoutManager = MainViewLayout(components: components)  // 레이아웃 관리
    private let dataManager = MainViewDataManager()  // 데이터 관리
    private var quickActionButtons: [UIButton] = []  // 빠른 버튼 액션들

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataManager()
        loadData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()  // 화면이 나타날 때마다 데이터 새로고침
    }

    private func setupUI() {
        view.backgroundColor = UIColor.headerBeige
        self.navigationController?.navigationBar.isHidden = true
        layoutManager.setupViewHierarchy(in: view)  // 뷰 계층구조 설정
        layoutManager.setupConstraints(in: view)  // 오토 레이아웃 제약조건 설정
        setupDynamicContent()  // 동적 콘텐츠 설정
        setupActions()  // 버튼 액션 연결
    }

    private func setupDynamicContent() {
        quickActionButtons = components.setupQuickActionButtons()  // 빠른 액션 버튼들 설정
        setupMyTasksViews()  // 내 담당 할일 설정
        setupRecentActivityViews()  // 최근 활동 설정
    }

    private func setupActions() {
        // 알림 버튼 액션 연결
        components.notificationButton.addTarget(
            self, action: #selector(notificationButtonTapped), for: .touchUpInside)

        // 빠른 액션 버튼들 액션 연결
        for (index, button) in quickActionButtons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(quickActionButtonTapped(_:)), for: .touchUpInside)
        }
    }

    private func setupDataManager() {
        dataManager.delegate = self
    }

    private func setupMyTasksViews() {
        /// 더미 데이터들

        // 진행 중인 할 일 1
        let inProgressTask1 = components.createTaskView(
            title: "🍽️ 설거지",
            status: "진행중",
            statusColor: UIColor.mainOrange,
            description: "식사 후 설거지 • 1시간 전 시작"
        )

        // 진행 중인 할 일 2
        let inProgressTask2 = components.createTaskView(
            title: "👕 빨래 널기",
            status: "진행중",
            statusColor: UIColor.mainOrange,
            description: "세탁기 완료 • 30분 전 시작"
        )

        // 대기 중인 할 일
        let pendingTask = components.createTaskView(
            title: "🧹 청소기 돌리기",
            status: "대기",
            statusColor: UIColor.textGray,
            description: "거실 청소 • 오늘까지"
        )

        components.myTasksStackView.addArrangedSubview(inProgressTask1)
        components.myTasksStackView.addArrangedSubview(inProgressTask2)
        components.myTasksStackView.addArrangedSubview(pendingTask)
    }

    private func setupRecentActivityViews() {
        /// 더미 데이터들

        // 완료된 할 일
        let completedActivity = components.createActivityView(
            title: "✅ 예슬님이 '빨래 개기' 완료",
            time: "30분 전",
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.1)
        )

        // 승인 대기 할 일
        let pendingActivity = components.createActivityView(
            title: "⏳ 관혁님의 '쓰레기 분리수거' 승인대기",
            time: "1시간 전",
            backgroundColor: UIColor.secondaryOrange.withAlphaComponent(0.1)
        )

        components.recentActivityStackView.addArrangedSubview(completedActivity)
        components.recentActivityStackView.addArrangedSubview(pendingActivity)
    }

    private func loadData() {
        dataManager.loadInitialData()
    }

    private func refreshData() {
        dataManager.refreshData()
    }

    @objc private func notificationButtonTapped() {
        print("알림 버튼 탭됨")
        // TODO: - 알림 화면으로 이동
    }

    @objc private func quickActionButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("새 퀘스트 버튼 탭됨")
            // TODO: - 새 퀘스트 생성 화면으로 이동
        case 1:
            print("검색 버튼 탭됨")
            // TODO: - 검색 화면으로 이동
        case 2:
            print("초대 버튼 탭됨")
            // TODO: - 가족 초대 화면으로 이동
        case 3:
            print("승인 버튼 탭됨")
            // TODO: - 승인 관리 화면으로 이동
        default:
            break
        }
    }

    private func updateUI(with user: User) {
        components.userNameLabel.text = dataManager.formatUserDisplayName(from: user)
        components.pointsLabel.text = dataManager.formatUserPoints(from: user)
    }

    private func updateUI(with family: Family) {
        components.familyNameLabel.text = dataManager.formatFamilyName(from: family)
    }

    private func updateUI(with stats: UserStatistics) {
        let progress = Float(stats.completionRate)
        components.progressView.progress = progress
        components.progressLabel.text = dataManager.formatCompletionRate(
            completed: stats.completedQuests, total: stats.totalQuests)
        components.setupCategoryStatsIcons(with: stats.categoryStats)
    }

    private func updateMyTasks(with quests: [Quest]) {
        // 기존 할 일들 제거
        components.myTasksStackView.arrangedSubviews.forEach { view in
            components.myTasksStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // 새로운 할 일들 추가
        for quest in quests.prefix(3) {  // 최대 3개만 표시
            let statusColor = quest.status == .inProgress ? UIColor.mainOrange : UIColor.textGray
            let statusText = quest.status.displayName

            let taskView = components.createTaskView(
                title: "\(quest.category.emoji) \(quest.title)",
                status: statusText,
                statusColor: statusColor,
                description: quest.description ?? ""
            )

            components.myTasksStackView.addArrangedSubview(taskView)
        }
    }

    private func updateRecentActivity(with activities: [String]) {
        // 기존 할 일들 제거
        components.recentActivityStackView.arrangedSubviews.forEach { view in
            components.recentActivityStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // 새로운 할 일들 추가
        for (index, activity) in activities.enumerated() {
            let backgroundColor =
            activity.contains("완료")
            ? UIColor.systemGreen.withAlphaComponent(0.1)
            : UIColor.secondaryOrange.withAlphaComponent(0.1)

            let time = index == 0 ? "30분 전" : "1시간 전"

            let activityView = components.createActivityView(
                title: activity,
                time: time,
                backgroundColor: backgroundColor
            )

            components.recentActivityStackView.addArrangedSubview(activityView)
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController: MainViewDataManagerDelegate {

    public func didLoadUserData(_ user: User?) {
        guard let user = user else { return }
        updateUI(with: user)
    }

    public func didLoadFamilyData(_ family: Family?) {
        guard let family = family else { return }
        updateUI(with: family)

        // 알림 개수 업데이트 (임시로 2개로 설정)
        components.notificationButton.setTitle("🔔 2", for: .normal)
    }

    public func didLoadQuests(_ quests: [Quest]) {
        updateMyTasks(with: quests)

        // 긴급 할 일 업데이트
        if let urgentQuest = quests.first(where: { $0.isDueToday || $0.isOverdue }) {
            components.urgentTaskTitleLabel.text = "\(urgentQuest.category.emoji) \(urgentQuest.title)"
            if let dueDate = urgentQuest.dueDate {
                components.urgentTaskTimeLabel.text = "⏰ \(dataManager.formatTimeRemaining(until: dueDate))"
            }
        }
    }

    public func didLoadStatistics(_ stats: UserStatistics?) {
        guard let stats = stats else { return }
        updateUI(with: stats)
    }

    public func didLoadRecentActivity(_ activities: [String]) {
        updateRecentActivity(with: activities)
    }

    public func didFailWithError(_ error: Error) {
        showError(error)
    }
}

#Preview {
    MainViewController()
}

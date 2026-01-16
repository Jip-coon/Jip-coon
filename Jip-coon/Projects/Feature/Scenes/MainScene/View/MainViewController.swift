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

/// 가족 관리 앱의 메인 화면을 담당하는 뷰 컨트롤러
/// - 가족 구성원들의 할 일, 통계, 활동 내역 등을 종합적으로 표시
/// - 실시간 데이터 업데이트를 위한 Combine 기반 반응형 아키텍처 구현
/// - 사용자 인터랙션에 따른 다양한 액션 처리 (퀘스트 완료, 연기, 상세보기 등)
/// - 캐싱 메커니즘을 통한 데이터 효율성 최적화
public class MainViewController: UIViewController {

    private let components = MainViewComponents()
    private lazy var layoutManager = MainViewLayout(components: components)
    private let viewModel: MainViewModel
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol
    private let questService: QuestServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    /// 의존성 주입을 통한 초기화
    /// - Parameters:
    ///   - viewModel: 메인 화면의 비즈니스 로직과 데이터 관리를 담당
    ///   - userService: 사용자 데이터 조회 및 관리 서비스
    ///   - familyService: 가족 구성원 및 가족 데이터 관리 서비스
    ///   - questService: 퀘스트 생성, 조회, 상태 변경 등의 서비스
    /// - Note: 각 서비스를 외부에서 주입받아 테스트 용이성과 모듈성 확보
    public init(
        viewModel: MainViewModel,
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.viewModel = viewModel
        self.userService = userService
        self.familyService = familyService
        self.questService = questService
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Public Methods

    /// 외부에서 데이터 리프레시를 요청할 때 사용
    public func refreshData() {
        viewModel.refreshDataIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 뷰 로드 시 초기 설정을 수행하는 메소드
    /// - UI 컴포넌트 및 레이아웃 설정
    /// - ViewModel의 데이터 변경을 UI에 바인딩하는 Combine 구독 설정
    /// - 버튼 등의 사용자 인터랙션 액션 설정
    /// - 알림 센터 옵저버 등록으로 외부 이벤트 처리
    /// - 초기 데이터 로딩을 통해 화면에 필요한 모든 정보 조회
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCombineBindings()
        setupActions()
        setupNotifications()
        viewModel.loadInitialData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
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

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
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
        // 퀘스트가 생성되었으므로 데이터를 강제 리프레시
        viewModel.forceRefreshData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.headerBeige
        layoutManager.setupViewHierarchy(in: view)
        layoutManager.setupConstraints(in: view)
        setupQuickActions()
    }

    private func setupActions() {
        // 가족 생성 버튼 액션
        components.createFamilyButton.addTarget(
            self,
            action: #selector(createFamilyButtonTapped),
            for: .touchUpInside
        )

        // 알림 버튼 액션
        components.notificationButton.addTarget(
            self,
            action: #selector(notificationButtonTapped),
            for: .touchUpInside
        )
    }

    @objc private func createFamilyButtonTapped() {
//        showFamilyCreationScreen()
    }

//    private func showFamilyCreationScreen() {
//        let familyCreationVC = FamilyCreationViewController(
//            familyService: familyService,
//            userService: userService
//        )
//        familyCreationVC.onFamilyCreated = { [weak self] in
//            // 가족 생성 완료 후 메인 화면으로 돌아와서 데이터 리프레시
//            self?.viewModel.loadInitialData(forceRefresh: true)
//        }
//
//        let navigationController = UINavigationController(rootViewController: familyCreationVC)
//        navigationController.modalPresentationStyle = .fullScreen
//        present(navigationController, animated: true)
//    }

    private func updateFamilyInfoView(with family: Family?) {
        // 기존 서브뷰들 제거
        components.familyInfoView.subviews.forEach { $0.removeFromSuperview() }

        if let family = family {
            // 가족이 있는 경우: 가족 이름과 알림 버튼 표시
            components.familyInfoView.addSubview(components.familyNameLabel)
            components.familyInfoView.addSubview(components.notificationButton)

            components.familyNameLabel.text = family.name

            NSLayoutConstraint.activate([
                components.familyNameLabel.topAnchor.constraint(equalTo: components.familyInfoView.topAnchor),
                components.familyNameLabel.leadingAnchor.constraint(equalTo: components.familyInfoView.leadingAnchor),
                components.familyNameLabel.trailingAnchor.constraint(equalTo: components.familyInfoView.trailingAnchor),

                components.notificationButton.topAnchor.constraint(equalTo: components.familyNameLabel.bottomAnchor, constant: 8),
                components.notificationButton.trailingAnchor.constraint(equalTo: components.familyInfoView.trailingAnchor),
                components.notificationButton.bottomAnchor.constraint(equalTo: components.familyInfoView.bottomAnchor),
                components.notificationButton.widthAnchor.constraint(equalToConstant: 50),
                components.notificationButton.heightAnchor.constraint(equalToConstant: 24)
            ])
        } else {
            // 가족이 없는 경우: 가족 생성 버튼 표시
            components.familyInfoView.addSubview(components.createFamilyButton)

            NSLayoutConstraint.activate([
                components.createFamilyButton.leadingAnchor.constraint(equalTo: components.familyInfoView.leadingAnchor),
                components.createFamilyButton.trailingAnchor.constraint(equalTo: components.familyInfoView.trailingAnchor),
                components.createFamilyButton.topAnchor.constraint(equalTo: components.familyInfoView.topAnchor),
                components.createFamilyButton.bottomAnchor.constraint(equalTo: components.familyInfoView.bottomAnchor)
            ])
        }
    }

    // MARK: - 데이터 바인딩 설정

    /// ViewModel의 데이터 변경을 UI 컴포넌트에 바인딩하는 메소드
    /// - 각 데이터 타입별로 별도의 구독을 설정하여 효율적인 업데이트 수행
    /// - Combine의 Publisher-Subscriber 패턴을 활용한 반응형 프로그래밍 구현
    /// - 메인 스레드에서 UI 업데이트를 보장하기 위해 receive(on: DispatchQueue.main) 사용
    private func setupCombineBindings() {
        // 사용자 정보 변경 시 헤더 영역 업데이트
        // nil 값 필터링 후 메인 스레드에서 UI 업데이트 수행
        viewModel.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.components.userNameLabel.text = user.name
                self?.components.pointsLabel.text = "\(user.points)P"
            }
            .store(in: &cancellables)

        // 가족 정보 변경 시 UI 업데이트
        viewModel.$family
            .receive(on: DispatchQueue.main)
            .sink { [weak self] family in
                self?.updateFamilyInfoView(with: family)
            }
            .store(in: &cancellables)

        // 긴급 퀘스트 목록 변경 시 긴급 작업 섹션 업데이트
        // 각 퀘스트 아이템에 탭 핸들러 부착하여 사용자 인터랙션 처리
        viewModel.$urgentQuests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quests in
                self?.components.setupUrgentTasks(with: quests) { quest in
                    self?.handleUrgentTaskTapped(quest)
                }
            }
            .store(in: &cancellables)

        // 긴급 퀘스트 개수 변경 시 카운트 레이블 업데이트
        // 실시간으로 긴급 작업의 개수를 사용자에게 표시
        viewModel.$urgentCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.components.urgentCountLabel.text = count
            }
            .store(in: &cancellables)

        // 내 작업과 가족 구성원 데이터를 결합하여 '내 작업' 섹션 설정
        // Publishers.CombineLatest를 사용하여 두 개의 퍼블리셔를 동시에 구독
        // 가족 구성원 정보를 활용하여 작업의 담당자 표시 등의 기능 구현
        Publishers.CombineLatest(viewModel.$myTasks, viewModel.$familyMembers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks, members in
                self?.components
                    .setupMyTasks(with: tasks, familyMembers: members) { task in
                        self?.handleMyTaskTapped(task)
                    }
            }
            .store(in: &cancellables)

        // 주간 완료율 통계 변경 시 프로그레스 바 업데이트
        // 완료율을 0-1 범위로 변환하여 UIProgressView에 설정
        viewModel.$weeklyStats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                let progress = stats.completionRate / 100.0
                self?.components.progressView.progress = Float(progress)
            }
            .store(in: &cancellables)

        // 진행 상황 텍스트 변경 시 프로그레스 레이블 업데이트
        // "이번 주 5/7 완료" 등의 형식으로 표시
        viewModel.$progressText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.components.progressLabel.text = progress
            }
            .store(in: &cancellables)

        // 카테고리별 통계 변경 시 아이콘과 카운트 표시 업데이트
        // 각 카테고리의 완료된 작업 수를 시각적으로 표현
        viewModel.$categoryStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.setupCategoryStats(stats)
            }
            .store(in: &cancellables)

        // 최근 활동 목록 변경 시 활동 피드 섹션 업데이트
        // 각 활동 아이템에 탭 핸들러를 부착하여 상세 화면 이동 등 처리
        viewModel.$recentActivities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.components
                    .setupRecentActivities(with: activities) { activity in
                        self?.handleRecentActivityTapped(activity)
                    }
            }
            .store(in: &cancellables)

        // 로딩 상태 변경에 따른 UI 응답성 제어
        // 로딩 중에는 사용자 인터랙션 비활성화로 UX 개선
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

        // 에러 발생 시 사용자에게 알림 표시
        // 네트워크 오류, 데이터 로딩 실패 등의 상황에서 피드백 제공
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)

        // 승인 대기 중인 퀘스트 개수 모니터링
        // 추후 승인 버튼에 배지 형태로 표시하여 대기 중인 작업 알림
        viewModel.$pendingApprovalCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                // 추후 승인 버튼에 배지 표시 가능
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
        // 퀘스트 완료 후 캐시 무효화하여 다음 뷰 로드 시 최신 데이터 반영
        viewModel.invalidateCache()
        // 필요한 경우에만 데이터 리프레시
        viewModel.refreshDataIfNeeded()
    }

    private func showQuestDetails(_ quest: Quest) {
        // TODO: - 할 일 상세 화면으로 이동 구현
    }

    private func postponeQuest(_ quest: Quest) {
        showPostponeAlert(for: quest)
    }

    // MARK: - Helper Methods

    private func setupCategoryStats(_ stats: [CategoryStatistic]) {
        let categoryStats: [(QuestCategory, Int)] = stats.map {
            ($0.category, $0.count)
        }
        components
            .setupCategoryStatsIcons(with: categoryStats) {
                [weak self] category,
                count in
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
        let urgencyLevel = QuestUrgencyCalculator.determineUrgencyLevel(
            for: quest
        )

        let alert = UIAlertController(
            title: "\(quest.category.emoji) \(quest.title)",
            message: QuestUrgencyCalculator
                .getUrgentTaskMessage(for: quest, urgencyLevel: urgencyLevel),
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
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController {

    private func handleQuickActionTapped(_ action: QuickAction) {
        switch action.type {
        case .newQuest:
            navigationItem.backButtonTitle = ""
            let addQuestViewController = AddQuestViewController(
                userService: userService,
                familyService: familyService,
                questService: questService
            )
            navigationController?
                .pushViewController(addQuestViewController, animated: true)
            break
        case .search:
            // TODO: - 검색 화면으로 이동
            break
        case .invite:
            // TODO: - 초대 화면으로 이동
            break
        case .approval:
            navigationItem.backButtonTitle = ""
            let approvalViewController = ApprovalViewController(
                questService: questService,
                userService: userService
            )
            navigationController?
                .pushViewController(approvalViewController, animated: true)
            break
        }
    }

    private func handleMyTaskTapped(_ quest: Quest) {
        // TODO: - 할일 상세 화면으로 이동
        let questDetailViewController = QuestDetailViewController(
            quest: quest,
            questService: questService,
            userService: userService
        )
        navigationItem.backButtonTitle = ""
        navigationController?
            .pushViewController(questDetailViewController, animated: true)
    }

    private func handleRecentActivityTapped(_ activity: RecentActivity) {
        // TODO: - 활동 상세 화면으로 이동
    }

    private func handleCategoryStatTapped(
        _ category: QuestCategory,
        count: Int
    ) {
        // TODO: - 해당 카테고리 할일 목록 화면으로 이동
    }
}

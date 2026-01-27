//
//  HomeViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import UIKit
import Core
import Combine

/// 홈 화면 (나의할일 목록)
public class HomeViewController: UIViewController {
    
    /// 필터 타입 정의
    private enum FilterType: Int {
        case collection = 0  // 나의할일
        case urgent = 1      // 긴급할일
        
        var title: String {
            switch self {
            case .collection: return "나의할일"
            case .urgent: return "긴급할일"
            }
        }
        
        var icon: String {
            switch self {
            case .collection: return "archivebox.fill"
            case .urgent: return "light.beacon.max.fill"
            }
        }
    }
    
    /// 현재 선택된 필터 (기본값: 나의할일)
    private var selectedFilter: FilterType = .collection
    
    /// 현재 표시 중인 자식 ViewController
    private var currentContentViewController: UIViewController?
    
    // MARK: - Services
    
    private let userService: UserServiceProtocol?
    private let familyService: FamilyServiceProtocol?
    private let questService: QuestServiceProtocol?
    
    // MARK: - Subscriptions
    
    private var cancellables = Set<AnyCancellable>()
    private var questSubscription: AnyCancellable?
    
    // MARK: - UI Components
    
    /// 네비게이션 바
    private lazy var navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// 가족 정보 컨테이너 뷰
    private lazy var familyInfoView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 가족 생성 버튼 (가족이 없을 때 표시)
    private lazy var createFamilyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ 가족 만들기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(createFamilyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 가족 이름 타이틀 (가족이 있을 때 표시)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "가족이름"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.isUserInteractionEnabled = true
        return label
    }()
    
    /// 알림 버튼
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        return button
    }()
    
    /// 필터 버튼 컨테이너
    private lazy var filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    /// 콘텐츠 컨테이너 뷰 (자식 ViewController가 표시될 영역)
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // MARK: - Initialization
    
    /// 서비스 주입을 통한 초기화
    public init(
        userService: UserServiceProtocol? = nil,
        familyService: FamilyServiceProtocol? = nil,
        questService: QuestServiceProtocol? = nil
    ) {
        self.userService = userService
        self.familyService = familyService
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
        setupFilterButtons()
        setupTraitChangeObserver()
        loadFamilyName()
        setupRealtimeQuestObservation()
    }
    
    /// 가족 정보 로드 및 UI 업데이트
    private func loadFamilyName() {
        guard let userService = userService,
              let familyService = familyService else {
            updateFamilyInfoView(with: nil)
            return
        }
        
        Task {
            do {
                // 현재 사용자 정보 가져오기
                let currentUser = try await userService.getCurrentUser()
                
                // 사용자가 속한 가족 ID가 있는지 확인
                guard let familyId = currentUser?.familyId else {
                    await MainActor.run {
                        self.updateFamilyInfoView(with: nil)
                    }
                    return
                }
                
                // 가족 정보 가져오기
                let family = try await familyService.getFamily(by: familyId)
                
                // UI 업데이트
                await MainActor.run {
                    self.updateFamilyInfoView(with: family)
                }
            } catch {
                await MainActor.run {
                    self.updateFamilyInfoView(with: nil)
                }
            }
        }
    }
    
    /// 가족 정보에 따라 UI 업데이트
    private func updateFamilyInfoView(with family: Family?) {
        // 기존 서브뷰들 제거
        familyInfoView.subviews.forEach { $0.removeFromSuperview() }
        
        if let family = family {
            // 가족이 있는 경우: 가족 이름 레이블과 알림 버튼 표시
            familyInfoView.addSubview(titleLabel)
            familyInfoView.addSubview(notificationButton)
            
            titleLabel.text = family.name
            
            // 기존 제스처 제거 후 새로 추가
            titleLabel.gestureRecognizers?.forEach { titleLabel.removeGestureRecognizer($0) }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(familyNameTapped))
            titleLabel.addGestureRecognizer(tapGesture)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            notificationButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: familyInfoView.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: familyInfoView.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: familyInfoView.bottomAnchor),
                
                notificationButton.trailingAnchor.constraint(equalTo: familyInfoView.trailingAnchor),
                notificationButton.centerYAnchor.constraint(equalTo: familyInfoView.centerYAnchor),
                notificationButton.widthAnchor.constraint(equalToConstant: 44),
                notificationButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        } else {
            // 가족이 없는 경우: 가족 생성 버튼 표시
            familyInfoView.addSubview(createFamilyButton)
            
            createFamilyButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                createFamilyButton.leadingAnchor.constraint(equalTo: familyInfoView.leadingAnchor),
                createFamilyButton.topAnchor.constraint(equalTo: familyInfoView.topAnchor),
                createFamilyButton.bottomAnchor.constraint(equalTo: familyInfoView.bottomAnchor)
            ])
        }
    }
    
    /// 다크모드 전환 감지 설정
    private func setupTraitChangeObserver() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.updateFilterButtonBorderColors()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 뷰 계층 구조 설정
        view.addSubview(navigationBar)
        navigationBar.addSubview(familyInfoView)
        
        view.addSubview(filterStackView)
        view.addSubview(contentContainerView)
        
        setupConstraints()
        
        // 초기 콘텐츠 로드 (나의할일)
        loadContentForFilter(.collection)
    }
    
    /// Auto Layout 제약 조건 설정
    private func setupConstraints() {
        [navigationBar, familyInfoView, filterStackView,
         contentContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // 네비게이션 바
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            familyInfoView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 24),
            familyInfoView.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            familyInfoView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -24),
            
            // 필터 영역
            filterStackView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            filterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            filterStackView.heightAnchor.constraint(equalToConstant: 90),
            
            // 콘텐츠 컨테이너 영역
            contentContainerView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: 16),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    /// 필터 버튼 생성 및 추가
    private func setupFilterButtons() {
        let filterTypes: [FilterType] = [.collection, .urgent]
        
        for (index, filterType) in filterTypes.enumerated() {
            let button = createFilterButton(for: filterType, showSeparator: index == 0)
            filterStackView.addArrangedSubview(button)
        }
        
        // 투명한 더미 버튼 2개 추가 (레이아웃 조정용)
        for _ in 0..<2 {
            let dummyButton = createDummyButton()
            filterStackView.addArrangedSubview(dummyButton)
        }
    }
    
    /// 투명한 더미 버튼 생성 (선택 불가)
    private func createDummyButton() -> UIView {
        let containerView = UIView()
        containerView.isUserInteractionEnabled = false
        return containerView
    }
    
    /// 필터 버튼 생성
    private func createFilterButton(for filterType: FilterType, showSeparator: Bool) -> UIView {
        let containerView = UIView()
        let isSelected = filterType == selectedFilter
        
        // 필터 버튼 생성
        let button = UIButton(type: .system)
        button.tag = filterType.rawValue
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: filterType.icon, withConfiguration: iconConfig), for: .normal)
        button.tintColor = .label
        button.backgroundColor = .clear
        button.layer.cornerRadius = 26
        button.layer.borderWidth = 1.5
        button.layer.borderColor = isSelected ? UIColor.label.cgColor : UIColor.systemGray5.cgColor
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        // 필터 라벨 생성
        let label = UILabel()
        label.text = filterType.title
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        
        containerView.addSubview(button)
        containerView.addSubview(label)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 52),
            button.heightAnchor.constraint(equalToConstant: 52),
            
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ]
        
        // 첫 번째 버튼에만 구분선 추가
        if showSeparator {
            let separator = UIView()
            separator.backgroundColor = .systemGray4
            containerView.addSubview(separator)
            
            separator.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                separator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                separator.widthAnchor.constraint(equalToConstant: 1),
                separator.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
        return containerView
    }
    
    // MARK: - Actions
    
    /// 필터 버튼 탭 이벤트
    @objc private func filterButtonTapped(_ sender: UIButton) {
        guard let newFilter = FilterType(rawValue: sender.tag) else { return }
        selectedFilter = newFilter
        updateFilterButtonBorderColors()
        
        // 필터에 따른 콘텐츠 로드
        loadContentForFilter(newFilter)
    }
    
    /// 모든 필터 버튼의 테두리 색상 업데이트
    private func updateFilterButtonBorderColors() {
        for case let containerView in filterStackView.arrangedSubviews {
            guard let button = containerView.subviews.first(where: { $0 is UIButton }) as? UIButton else {
                continue
            }
            let isSelected = button.tag == selectedFilter.rawValue
            button.layer.borderColor = isSelected ? UIColor.label.cgColor : UIColor.systemGray5.cgColor
        }
    }
    
    /// 알림 버튼 탭 이벤트
    @objc private func notificationTapped() {
        // TODO: 알림 화면으로 이동
    }
    
    // MARK: - Content Management
    
    /// 필터에 따른 콘텐츠 로드
    private func loadContentForFilter(_ filter: FilterType) {
        let viewController: UIViewController
        
        switch filter {
        case .collection:
            // 나의할일 - MyTasksViewController 표시
            viewController = createMyTasksViewController()
        case .urgent:
            // 긴급할일 - UrgentQuestViewController 표시
            viewController = createUrgentQuestViewController()
        }
        
        switchContentViewController(to: viewController)
    }
    
    /// 콘텐츠 ViewController 교체
    private func switchContentViewController(to viewController: UIViewController) {
        // 기존 자식 제거
        if let currentChild = currentContentViewController {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
        // 새 자식 추가
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
        currentContentViewController = viewController
    }
    
    /// MyTasksViewController 생성
    private func createMyTasksViewController() -> UIViewController {
        // 서비스가 없으면 빈 상태 뷰 반환
        guard let userService = userService,
              let questService = questService else {
            return createEmptyStateViewController()
        }
        
        return MyTasksViewController(
            userService: userService,
            questService: questService
        )
    }
    
    /// AllQuestViewController 생성
    private func createAllQuestViewController() -> UIViewController {
        // 서비스가 없으면 빈 상태 뷰 반환
        guard let userService = userService,
              let questService = questService else {
            return createEmptyStateViewController()
        }
        
        let viewModel = AllQuestViewModel(
            userService: userService,
            questService: questService
        )
        return AllQuestViewController(viewModel: viewModel)
    }
    
    /// UrgentQuestViewController 생성
    private func createUrgentQuestViewController() -> UIViewController {
        // 서비스가 없으면 빈 상태 뷰 반환
        guard let userService = userService,
              let questService = questService else {
            return createEmptyStateViewController()
        }
        
        return UrgentQuestViewController(
            userService: userService,
            questService: questService
        )
    }
    
    /// 빈 상태 ViewController 생성
    private func createEmptyStateViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        iconView.image = UIImage(systemName: "archivebox", withConfiguration: config)
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "집안일이 없어요"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(iconView)
        vc.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 100),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        ])
        
        return vc
    }
    
    // MARK: - Actions
    
    /// 가족 생성 버튼 탭
    @objc private func createFamilyButtonTapped() {
        showFamilyCreationScreen()
    }
    
    /// 가족 이름 탭
    @objc private func familyNameTapped() {
        showFamilyInfoPopup()
    }
    
    /// 가족 생성 화면 표시
    private func showFamilyCreationScreen() {
        guard let familyService = familyService,
              let userService = userService else {
            showAlert(title: "오류", message: "서비스를 사용할 수 없습니다.")
            return
        }
        
        let familyCreationVC = FamilyCreationViewController(
            familyService: familyService,
            userService: userService
        )
        familyCreationVC.onFamilyCreated = { [weak self] in
            // 가족 생성 완료 후 데이터 리프레시
            self?.loadFamilyName()
        }
        
        let navigationController = UINavigationController(rootViewController: familyCreationVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    /// 가족 정보 팝업 표시
    private func showFamilyInfoPopup() {
        guard let familyService = familyService,
              let userService = userService else {
            showAlert(title: "오류", message: "서비스를 사용할 수 없습니다.")
            return
        }
        
        Task {
            do {
                let currentUser = try await userService.getCurrentUser()
                guard let familyId = currentUser?.familyId else {
                    await MainActor.run {
                        self.showAlert(title: "오류", message: "가족 정보를 불러올 수 없습니다.")
                    }
                    return
                }
                
                let family = try await familyService.getFamily(by: familyId)
                
                await MainActor.run {
                    guard let family = family else {
                        self.showAlert(title: "오류", message: "가족 정보를 불러올 수 없습니다.")
                        return
                    }
                    
                    let alert = UIAlertController(
                        title: "가족 정보",
                        message: """
                        가족명: \(family.name)
                        
                        초대코드: \(family.inviteCode)
                        """,
                        preferredStyle: .alert
                    )
                    
                    // 초대코드 복사 액션
                    alert.addAction(UIAlertAction(title: "초대코드 복사", style: .default) { [weak self] _ in
                        UIPasteboard.general.string = family.inviteCode
                        self?.showAlert(title: "완료", message: "초대코드가 클립보드에 복사되었습니다.")
                    })
                    
                    // 공유 액션
                    alert.addAction(UIAlertAction(title: "공유하기", style: .default) { [weak self] _ in
                        let shareText = "우리 가족 '\(family.name)'에 참여하세요!\n초대코드: \(family.inviteCode)"
                        let activityVC = UIActivityViewController(
                            activityItems: [shareText],
                            applicationActivities: nil
                        )
                        self?.present(activityVC, animated: true)
                    })
                    
                    alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
                    
                    self.present(alert, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "오류", message: "가족 정보를 불러올 수 없습니다.")
                }
            }
        }
    }
    
    // MARK: - Realtime Updates
    
    /// 실시간 퀘스트 관찰 설정
    private func setupRealtimeQuestObservation() {
        guard let userService = userService else { return }
        
        Task {
            do {
                if let currentUser = try await userService.getCurrentUser(),
                   let familyId = currentUser.familyId {
                    await startRealtimeObservation(familyId: familyId)
                }
            } catch {
                // 실시간 관찰 설정 실패
            }
        }
    }
    
    /// 실시간 관찰 시작
    private func startRealtimeObservation(familyId: String) async {
        guard let questService = questService else { return }
        
        await MainActor.run {
            questSubscription?.cancel()
        }
        
        questSubscription = questService
            .observeFamilyQuests(familyId: familyId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    // 실시간 관찰 에러
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] quests in
                self?.notifyQuestUpdate()
            }
    }
    
    /// 퀘스트 업데이트 알림 전송 (자식 뷰 컨트롤러들에게 알림)
    private func notifyQuestUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name("QuestCreated"), object: nil)
    }
    
    // MARK: - Helpers
    
    /// 알림 표시 헬퍼 메서드
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

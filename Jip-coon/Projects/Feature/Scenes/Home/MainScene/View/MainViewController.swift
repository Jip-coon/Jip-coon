//
//  MainViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/25/26.
//

import Combine
import Core
import UIKit

/// 메인 화면
public class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    /// 현재 표시 중인 자식 ViewController
    private var currentChildViewController: UIViewController?
    
    // MARK: - UI Components
    
    /// 컨텐츠 컨테이너 뷰 (자식 ViewController가 표시될 영역)
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// 하단 네비게이션 탭바
    private lazy var tabBar: MainTabBar = {
        let tabBar = MainTabBar()
        return tabBar
    }()
    
    // MARK: - Initialization
    
    /// 서비스 주입을 통한 초기화
    public init(
        userService: UserServiceProtocol? = nil,
        familyService: FamilyServiceProtocol? = nil,
        questService: QuestServiceProtocol? = nil
    ) {
        self.viewModel = MainViewModel(
            userService: userService,
            familyService: familyService,
            questService: questService
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupTabBarCallbacks()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await viewModel.updateTimeZone()
            viewModel.resetUserBadgeCount()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 뷰 계층 구조 설정
        view.addSubview(contentContainerView)
        view.addSubview(tabBar)
        
        setupConstraints()
        
        // 초기 화면 로드 (첫 번째 탭)
        loadInitialViewController()
    }
    
    /// Auto Layout 제약 조건 설정
    private func setupConstraints() {
        [contentContainerView, tabBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // 컨텐츠 컨테이너 뷰 (상단 전체 영역)
            contentContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            // 하단 네비게이션 바
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 90),
        ])
    }
    
    /// ViewModel 바인딩
    private func bindViewModel() {
        viewModel.$selectedTabIndex
            .sink { [weak self] index in
                self?.handleTabChange(to: index)
            }
            .store(in: &cancellables)
    }
    
    /// 탭바 설정
    private func setupTabBarCallbacks() {
        // 탭 선택 콜백
        tabBar.onTabSelected = { [weak self] tag in
            self?.viewModel.selectTab(at: tag)
        }
        
        // 플러스 버튼 콜백
        tabBar.onPlusButtonTapped = { [weak self] in
            self?.handlePlusButtonTapped()
        }
    }
    
    // MARK: - Child ViewController Management
    
    /// 초기 화면 로드
    private func loadInitialViewController() {
        // 첫 번째 탭(홈) 화면 로드
        switchToViewController(createHomeViewController())
    }
    
    /// 탭 변경 처리
    private func handleTabChange(to index: Int) {
        let viewController: UIViewController
        
        switch index {
            case 0: // 홈
                viewController = createHomeViewController()
            case 1: // 전체 퀘스트
                viewController = createAllQuestViewController()
            case 3: // 랭킹
                viewController = createRankingViewController()
            case 4: // 설정
                viewController = createSettingViewController()
            default:
                return
        }
        
        switchToViewController(viewController)
    }
    
    /// HomeViewController 생성
    private func createHomeViewController() -> UIViewController {
        guard let userService = viewModel.getUserService(),
              let familyService = viewModel.getFamilyService(),
              let questService = viewModel.getQuestService() else {
            return createDefaultViewController(title: "홈", icon: "house")
        }
        
        let homeViewController = HomeViewController(
            userService: userService,
            familyService: familyService,
            questService: questService
        )
        
        let navigationController = UINavigationController(rootViewController: homeViewController)
        
        return navigationController
    }
    
    /// AllQuestViewController 생성
    private func createAllQuestViewController() -> UIViewController {
        guard let userService = viewModel.getUserService(),
              let questService = viewModel.getQuestService() else {
            return createDefaultViewController(title: "전체 퀘스트", icon: "text.page.fill")
        }
        
        let allQuestViewModel = AllQuestViewModel(
            userService: userService,
            questService: questService
        )
        
        let allQuestVC = AllQuestViewController(viewModel: allQuestViewModel)
        
        // NavigationController로 래핑
        let navigationController = UINavigationController(rootViewController: allQuestVC)
        return navigationController
    }
    
    /// RankingViewController 생성
    private func createRankingViewController() -> UIViewController {
        guard let userService = viewModel.getUserService(),
              let familyService = viewModel.getFamilyService() else {
            return createDefaultViewController(title: "랭킹", icon: "trophy")
        }
        
        return RankingViewController(
            userService: userService,
            familyService: familyService
        )
    }
    
    /// SettingViewController 생성
    private func createSettingViewController() -> UIViewController {
        let settingVC = SettingViewController()
        let navigationController = UINavigationController(rootViewController: settingVC)
        return navigationController
    }
    
    /// 자식 ViewController 교체
    private func switchToViewController(_ viewController: UIViewController) {
        // 기존 자식 제거
        if let currentChild = currentChildViewController {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
        // 새 자식 추가
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(viewController.view)
        
        // Auto Layout 제약 조건 설정
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
        
        currentChildViewController = viewController
    }
    
    /// 기본 ViewController 생성 (임시)
    private func createDefaultViewController(title: String, icon: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "\(title) 화면"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(iconView)
        vc.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor, constant: -40),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),
            
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        ])
        
        return vc
    }
    
    // MARK: - Actions
    
    /// 플러스 버튼 탭 처리
    private func handlePlusButtonTapped() {
        guard let userService = viewModel.getUserService(),
              let familyService = viewModel.getFamilyService(),
              let questService = viewModel.getQuestService() else {
            print("서비스를 사용할 수 없습니다.")
            return
        }
        
        let addQuestVC = AddQuestViewController(
            userService: userService,
            familyService: familyService,
            questService: questService
        )
        
        let navigationController = UINavigationController(rootViewController: addQuestVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

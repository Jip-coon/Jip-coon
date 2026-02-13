//
//  HomeViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import Combine
import Core
import UIKit

/// 홈 화면 (나의할일 목록)
final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var currentContentViewController: UIViewController?
    
    // MARK: - UI Components
    
    private lazy var headerView: HomeHeaderView = {
        let view = HomeHeaderView()
        view.delegate = self
        return view
    }()
    
    private lazy var filterBar: HomeFilterBar = {
        let view = HomeFilterBar()
        view.delegate = self
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // MARK: - Initialization
    
    init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.viewModel = HomeViewModel(
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTraitChangeObserver()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // 가족 정보 바인딩
        viewModel.$family
            .receive(on: DispatchQueue.main)
            .sink { [weak self] family in
                self?.headerView.update(with: family)
            }
            .store(in: &cancellables)
        
        // 부모 여부 바인딩
        viewModel.$isParent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isParent in
                self?.filterBar.setupButtons(isParent: isParent)
            }
            .store(in: &cancellables)
        
        // 필터 선택 바인딩
        viewModel.$selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                self?.loadContentForFilter(filter)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        [headerView, filterBar, contentContainerView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // 헤더 뷰 (상단 네비게이션 영역)
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // 필터 바
            filterBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            filterBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterBar.heightAnchor.constraint(equalToConstant: 90),
            
            // 콘텐츠 영역
            contentContainerView.topAnchor.constraint(equalTo: filterBar.bottomAnchor, constant: 16),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTraitChangeObserver() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, prev: UITraitCollection) in
            self.filterBar.refreshStyles()
        }
    }
    
    // MARK: - Content Management
    
    private func loadContentForFilter(_ filter: HomeFilterType) {
        let viewController: UIViewController
        
        switch filter {
            case .myTask:
                viewController = createMyTasksViewController()
            case .urgent:
                viewController = createUrgentQuestViewController()
            case .approval:
                viewController = createApprovalViewController()
        }
        
        switchContentViewController(to: viewController)
    }
    
    private func switchContentViewController(to viewController: UIViewController) {
        if let currentChild = currentContentViewController {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
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
    
    private func createMyTasksViewController() -> UIViewController {
        return MyTasksViewController(
            userService: viewModel.userService,
            questService: viewModel.questService
        )
    }
    
    private func createUrgentQuestViewController() -> UIViewController {
        return UrgentQuestViewController(
            userService: viewModel.userService,
            questService: viewModel.questService
        )
    }
    
    private func createApprovalViewController() -> UIViewController {
        return ApprovalViewController(
            questService: viewModel.questService,
            userService: viewModel.userService
        )
    }
    
    private func createEmptyStateViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        iconView.image = UIImage(systemName: "archivebox", withConfiguration: config)
        iconView.tintColor = .systemGray
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "집안일이 없어요"
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(iconView)
        vc.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        ])
        
        return vc
    }
    
    // MARK: - Actions
    
    private func showFamilyCreationScreen() {
        let vc = FamilyCreationViewController(
            familyService: viewModel.familyService,
            userService: viewModel.userService
        )
        vc.onFamilyCreated = { [weak self] in
            self?.viewModel.loadFamilyInfo()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func showFamilyInfoPopup() {
        guard let contents = viewModel.getFamilyInfoAlertContents() else { return }
        
        let alert = UIAlertController(
            title: contents.title,
            message: contents.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "초대코드 복사", style: .default) { _ in
            UIPasteboard.general.string = contents.inviteCode
        })
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func showNotificationView() {
        let notificationViewModel = NotificationViewModel(
            userService: viewModel.userService,
            questService: viewModel.questService
        )
        let notificationViewController = NotificationViewController(viewModel: notificationViewModel)
        notificationViewController.title = "알림"
        
        navigationController?.pushViewController(notificationViewController, animated: true)
    }
    
    public func forceSwitchToMyTask() {
        // 1. 뷰모델 데이터 변경
        viewModel.selectFilter(.myTask)
        
        // 2. 필터바 UI 변경 (버튼 테두리 등)
        filterBar.setFilter(.myTask)
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

// MARK: - Delegates

extension HomeViewController: HomeHeaderViewDelegate {
    func didTapCreateFamily() { showFamilyCreationScreen() }
    func didTapFamilyName() { showFamilyInfoPopup() }
    func didTapNotification() { showNotificationView() }
}

extension HomeViewController: HomeFilterBarDelegate {
    func didSelectFilter(_ filterType: HomeFilterType) {
        viewModel.selectFilter(filterType)
    }
}

//
//  NotificationViewController.swift
//  Feature
//
//  Created by 예슬 on 2/10/26.
//

import Combine
import UI
import UIKit

final class NotificationViewController: UIViewController {
    
    private let viewModel: NotificationViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .backgroundWhite
        tableView.separatorStyle = .none
        tableView.register(
            NotificationTableViewCell.self,
            forCellReuseIdentifier: NotificationTableViewCell.identifier
        )
        return tableView
    }()
    
    // MARK: - init
    
    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
        setupNavigationRightItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // 이동 이벤트 구독
        viewModel.$navigationDestination
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] destination in
                self?.handleNavigation(to: destination)
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigationRightItem() {
        let settingButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(didTapSetting)
        )
        navigationItem.rightBarButtonItem = settingButton
    }
    
    @objc private func didTapSetting() {
        let notificationSettingViewModel = NotificationSettingViewModel()
        let notificationSettingViewController = NotificationSettingViewController(
            viewModel: notificationSettingViewModel
        )
        navigationController?.pushViewController(notificationSettingViewController, animated: true)
    }
    
    private func handleNavigation(to destination: NotificationDestination) {
        switch destination {
            case .questDetail(let quest):
                let questDetailVC = QuestDetailViewController(
                    quest: quest,
                    questService: viewModel.questService,
                    userService: viewModel.userService
                )
                navigationController?.pushViewController(questDetailVC, animated: true)
                
            case .myTask:
                navigationController?.popViewController(animated: true)
                
                // 홈 화면의 필터를 '나의 할일'로 변경
                if let homeVC = navigationController?.topViewController as? HomeViewController {
                    homeVC.didSelectFilter(.myTask)
                    print("home")
                } else if let mainVC = navigationController?.topViewController as? MainViewController {
                    if let homeVC = mainVC.children.first(where: { $0 is HomeViewController }) as? HomeViewController {
                        homeVC.didSelectFilter(.myTask)
                        print("main")
                    }
                }
        }
    }
    
}

// MARK: - TableViewDelegate, TableViewDataSource

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .backgroundWhite
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.text = viewModel.sections[section].section.title
        
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18),
            label.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        return container
    }
    
    // MARK: - Row
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationTableViewCell.identifier,
            for: indexPath
        ) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        let sectionType = viewModel.sections[indexPath.section].section
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        
        cell.configureUI(notification: item, isToday: sectionType == .today)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectNotification(at: indexPath)
    }
    
}

//
//  NotificationSettingViewController.swift
//  Feature
//
//  Created by 예슬 on 2/6/26.
//

import Core
import Combine
import UI
import UIKit

final class NotificationSettingViewController: UIViewController {
    
    private let viewModel: NotificationSettingViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(
            NotificationSettingTableViewCell.self,
            forCellReuseIdentifier: NotificationSettingTableViewCell.identifier
        )
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }
    
    // MARK: - init
    
    init(
        viewModel: NotificationSettingViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI
    
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
        viewModel.$settings
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                if !self.viewModel.isDataLoaded {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        // 알림 권한 설정
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.viewModel.fetchSettings()
            }
            .store(in: &cancellables)
    }
    
    private func handleToggleAction(type: NotificationSettingType, isOn: Bool) {
        if !viewModel.isSystemAuthorized {
            // 권한이 없으면 얼럿 띄우기
            showPermissionAlert()
            
            // UI를 다시 OFF 상태로 되돌리기
            tableView.reloadData()
            return
        }
        
        // 권한이 있을 때만 뷰모델에 전달
        viewModel.toggleSetting(type: type, isOn: isOn)
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "알림 권한 필요",
            message: "알림을 켜려면 시스템 설정에서 알림 허용을 활성화해야 합니다.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        
        alert.addAction(settingsAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
}

// MARK: - TableViewDataSource, TableViewDelegate

extension NotificationSettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationSettingType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSettingTableViewCell.identifier,
            for: indexPath
        ) as? NotificationSettingTableViewCell
        else {
            return UITableViewCell()
        }
        
        let type = NotificationSettingType.allCases[indexPath.row]
        let value = viewModel.settings[type] ?? true
        
        cell.onToggle = { [weak self] type, isOn in
            self?.handleToggleAction(type: type, isOn: isOn)
        }
        
        cell.configureUI(type: type, isOn: value)
        
        return cell
    }
    
}

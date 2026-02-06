//
//  NotificationSettingViewController.swift
//  Feature
//
//  Created by 예슬 on 2/6/26.
//

import Core
import UI
import UIKit

final class NotificationSettingViewController: UIViewController {
    
    private var testValues: [NotificationSettingType: Bool] = [:]
    
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
        setupUI()
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
        
        NotificationSettingType.allCases.forEach {
            testValues[$0] = true
        }
    }
    
}

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
        let value = testValues[type] ?? true
        
        cell.onToggle = { [weak self] type, isOn in
            self?.testValues[type] = isOn
        }
        
        cell.configureUI(type: type, isOn: value)
        
        return cell
    }
    
}

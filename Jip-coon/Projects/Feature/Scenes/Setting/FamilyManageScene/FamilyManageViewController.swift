//
//  FamilyManageViewController.swift
//  Feature
//
//  Created by 심관혁 on 2/1/26.
//

import UIKit
import UI
import Core

public final class FamilyManageViewController: UIViewController {
    
    private let viewModel = FamilyManageViewModel()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "memberCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "inviteCodeCell")
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "가족 관리"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchData() {
        Task {
            do {
                try await viewModel.loadData()
                tableView.reloadData()
            } catch {
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func showEditFamilyNameAlert() {
        let alert = UIAlertController(title: "가족 이름 변경", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "가족 이름"
            textField.text = self?.viewModel.familyName
        }
        
        let confirmAction = UIAlertAction(title: "변경", style: .default) { [weak self] _ in
            guard let self = self,
                  let newName = alert.textFields?.first?.text,
                  !newName.isEmpty else { return }
            
            Task {
                do {
                    try await self.viewModel.updateFamilyName(newName: newName)
                    self.tableView.reloadData()
                } catch {
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showMemberOptions(for user: User) {
        let alert = UIAlertController(
            title: user.displayNameWithRole,
            message: "구성원 관리",
            preferredStyle: .actionSheet
        )
        
        // 역할 변경 액션
        let changeRoleTitle = user.role == .parent ? "자녀로 변경" : "부모로 변경"
        let changeRoleAction = UIAlertAction(title: changeRoleTitle, style: .default) { [weak self] _ in
            self?.handleChangeRole(user: user)
        }
        
        // 내보내기 액션
        let removeAction = UIAlertAction(title: "가족에서 내보내기", style: .destructive) { [weak self] _ in
            self?.handleRemoveMember(user: user)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(changeRoleAction)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func handleChangeRole(user: User) {
        let newRole: UserRole = user.role == .parent ? .child : .parent
        let message = "\(user.name)님의 역할을 \(newRole.displayName)(으)로 변경하시겠습니까?"
        
        let alert = UIAlertController(title: "역할 변경", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "변경", style: .default) { [weak self] _ in
            Task {
                do {
                    try await self?.viewModel.updateMemberRole(userId: user.id, newRole: newRole)
                    self?.tableView.reloadData()
                } catch {
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func handleRemoveMember(user: User) {
        let message = "\(user.name)님을 가족에서 내보내시겠습니까?"
        
        let alert = UIAlertController(title: "내보내기", message: message, preferredStyle: .alert)
        let removeAction = UIAlertAction(title: "내보내기", style: .destructive) { [weak self] _ in
            Task {
                do {
                    try await self?.viewModel.removeMember(userId: user.id)
                    self?.tableView.reloadData()
                } catch {
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension FamilyManageViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 0: 가족 정보, 1: 구성원 목록
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        return viewModel.familyMembers.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "가족 정보" }
        return "가족 구성원 (\(viewModel.familyMembers.count))"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // 가족 이름 셀
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "infoCell")
                var content = cell.defaultContentConfiguration()
                content.text = "가족 이름"
                content.secondaryText = viewModel.familyName
                cell.contentConfiguration = content
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                return cell
            } else {
                // 초대 코드 셀
                let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCodeCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "초대코드: \(viewModel.inviteCode)"
                content.secondaryText = "클릭하여 복사"
                content.secondaryTextProperties.color = .secondaryLabel
                cell.contentConfiguration = content
                cell.selectionStyle = .default
                return cell
            }
        } else {
            // 구성원 셀
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
            let user = viewModel.familyMembers[indexPath.row]
            
            var content = cell.defaultContentConfiguration()
            content.text = user.name
            content.secondaryText = user.role.displayName
            
            if viewModel.isCurrentUser(userId: user.id) {
                content.text = "\(user.name) (나)"
                content.textProperties.color = .systemBlue
            } else {
                content.textProperties.color = .label
            }
            
            cell.contentConfiguration = content
            
            if !viewModel.isCurrentUser(userId: user.id) {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
            
            cell.selectionStyle = .default
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                showEditFamilyNameAlert()
            } else {
                UIPasteboard.general.string = viewModel.inviteCode
                let alert = UIAlertController(title: "복사 완료", message: "초대 코드가 클립보드에 복사되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true)
            }
        } else {
            let user = viewModel.familyMembers[indexPath.row]
            if !viewModel.isCurrentUser(userId: user.id) {
                showMemberOptions(for: user)
            }
        }
    }
}

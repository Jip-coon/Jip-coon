//
//  SettingViewController.swift
//  Feature
//
//  Created by 심관혁 on 10/29/25.
//

import Core
import FirebaseAuth
import FirebaseFirestore
import UI
import UIKit

// MARK: - 설정 메뉴 데이터 모델

private enum SettingSection: Int, CaseIterable {
    case profile
    case familyManage
    case appSettings
    case support
    case account
    
    var title: String {
        switch self {
            case .profile:
                return "프로필"
            case .familyManage:
                return "가족 관리"
            case .appSettings:
                return "앱 설정"
            case .support:
                return "고객지원"
            case .account:
                return "계정 관리"
        }
    }
    
    var items: [SettingItem] {
        switch self {
            case .profile:
                return [.editProfile]
            case .familyManage:
                return [.manageFamily]
            case .appSettings:
                return [.notifications]
            case .support:
                return [.termsOfService, .privacyPolicy, .appVersion]
            case .account:
                return [.leaveFamily, .logout, .deleteAccount]
        }
    }
}

private enum SettingItem {
    case editProfile
    case manageFamily
    case notifications
    case termsOfService
    case privacyPolicy
    case appVersion
    case leaveFamily
    case logout
    case deleteAccount
    
    var title: String {
        switch self {
            case .editProfile: return "프로필 수정"
            case .manageFamily: return "가족 관리"
            case .notifications: return "알림 설정"
            case .termsOfService: return "서비스 이용약관"
            case .privacyPolicy: return "개인정보 처리방침"
            case .appVersion: return "앱 버전"
            case .leaveFamily: return "가족 탈퇴"
            case .logout: return "로그아웃"
            case .deleteAccount: return "회원 탈퇴"
        }
    }
}

// MARK: - SettingViewController

public final class SettingViewController: UIViewController {
    
    private let viewModel = SettingViewModel()
    
    // 현재 사용자 정보 (ViewModel에서 가져옴)
    private var currentUser: Core.User? {
        return viewModel.currentUser
    }
    
    private var dataSource: [(section: SettingSection, items: [SettingItem])] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "settingCell"
        )
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        Task { await loadCurrentUser() }
    }
    
    // MARK: - setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadCurrentUser() async {
        await viewModel.loadCurrentUser()
        updateDataSource()
        tableView.reloadData()
    }
    
    private func updateDataSource() {
        var newDataSource: [(section: SettingSection, items: [SettingItem])] = []
        
        for section in SettingSection.allCases {
            // 섹션 필터링
            if section == .familyManage {
                let isParentOrAdmin = currentUser?.isParent == true || currentUser?.isAdmin == true
                if !isParentOrAdmin { continue }
            }
            
            // 아이템 필터링
            var items = section.items
            if section == .account {
                if currentUser?.familyId == nil {
                    items.removeAll { $0 == .leaveFamily }
                }
            }
            
            newDataSource.append((section, items))
        }
        
        self.dataSource = newDataSource
    }
    
    private func handleLogout() {
        let signoutAlert = UIAlertController(
            title: "로그아웃",
            message: "로그아웃하시겠습니까?",
            preferredStyle: .alert
        )
        let okButton = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            Task {
                do {
                    try await self.viewModel.performLogout()
                    NotificationCenter.default
                        .post(
                            name: NSNotification.Name("LogoutSuccess"),
                            object: nil
                        )
                } catch {
                    print("로그아웃 실패: \(error.localizedDescription)")
                }
            }
        }
        let cancelButton = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        signoutAlert.addAction(okButton)
        signoutAlert.addAction(cancelButton)
        present(signoutAlert, animated: true, completion: nil)
    }
    
    /// 이메일 로그인 알림창
    private func showPasswordDeleteAlert() {
        let deleteAccountAlert = UIAlertController(
            title: "회원탈퇴",
            message: "회원탈퇴를 위해 비밀번호를 다시 입력해주세요.",
            preferredStyle: .alert
        )
        
        deleteAccountAlert.addTextField { textField in
            textField.placeholder = "비밀번호"
            textField.isSecureTextEntry = true
        }
        
        let okButton = UIAlertAction(title: "회원탈퇴", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let password = deleteAccountAlert.textFields?.first?.text,
                  !password.isEmpty else {
                self?.showErrorAlert(message: "비밀번호를 입력해주세요.")
                return
            }
            
            Task {
                do {
                    try await self.viewModel.performDeleteAccount(password: password)
                    
                    // 회원탈퇴 성공 Alert 표시
                    await MainActor.run {
                        self.hideLoading()
                        self.showSuccessAlert()
                    }
                } catch {
                    await MainActor.run {
                        self.hideLoading()
                        self.showErrorAlert(message: "회원탈퇴에 실패했습니다.")
                    }
                    print("회원 탈퇴 실패: \(error.localizedDescription)")
                }
            }
        }
        
        let cancelButton = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        
        deleteAccountAlert.addAction(okButton)
        deleteAccountAlert.addAction(cancelButton)
        present(deleteAccountAlert, animated: true, completion: nil)
    }
    
    // 소셜로그인 알림창
    private func showSocialDeleteAlert() {
        let alert = UIAlertController(
            title: "회원탈퇴",
            message: "정말로 회원탈퇴 하시겠습니까?\n재인증이 진행됩니다.",
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "회원탈퇴", style: .destructive) { [weak self] _ in
            guard let self else { return }
            
            self.showLoading()
            
            Task {
                do {
                    try await self.viewModel.performDeleteAccount(password: nil)
                    
                    // 회원탈퇴 성공 Alert 표시
                    await MainActor.run {
                        self.hideLoading()
                        self.showSuccessAlert()
                    }
                } catch {
                    await MainActor.run {
                        self.hideLoading()
                        self.showErrorAlert(message: "회원탈퇴에 실패했습니다.")
                    }
                    print("회원 탈퇴 실패: \(error.localizedDescription)")
                }
            }
        }
        
        alert.addAction(ok)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    /// 회원탈퇴 성공 알림
    private func showSuccessAlert() {
        let successAlert = UIAlertController(
            title: "회원탈퇴 완료",
            message: "성공적으로 처리되었습니다.",
            preferredStyle: .alert
        )
        successAlert.addAction(
            UIAlertAction(title: "확인", style: .default) { _ in
                NotificationCenter.default.post(
                    name: NSNotification.Name("LogoutSuccess"),
                    object: nil
                )
            })
        self.present(successAlert, animated: true)
    }
    
    /// 회원탈퇴
    private func handleDeleteAccount() {
        guard let providerID = viewModel.currentProviderID else {
            showErrorAlert(message: "로그인 정보를 확인할 수 없습니다.")
            return
        }
        
        if providerID == "password" {
            showPasswordDeleteAlert()
        } else {
            showSocialDeleteAlert()
        }
    }
    
    private func handleManageFamily() {
        let familyManageVC = FamilyManageViewController()
        navigationController?.pushViewController(familyManageVC, animated: true)
    }
    
    private func handleLeaveFamily() {
        let isUserAdmin = currentUser?.isAdmin == true
        let title = isUserAdmin ? "가족 그룹 삭제" : "가족 탈퇴"
        let message = isUserAdmin
        ? "관리자 권한을 가지고 있습니다.\n탈퇴 시 가족 그룹이 영구적으로 삭제되며,\n모든 구성원의 연결이 해제됩니다.\n정말 삭제하시겠습니까?"
        : "정말 가족을 탈퇴하시겠습니까?\n탈퇴 후에는 가족 정보를 볼 수 없습니다."
        let actionTitle = isUserAdmin ? "삭제" : "탈퇴"
        
        let leaveFamilyAlert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: actionTitle, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            Task {
                do {
                    try await self.viewModel.performLeaveFamily()
                    
                    let successAlert = UIAlertController(
                        title: "탈퇴 완료",
                        message: "가족 탈퇴가 완료되었습니다.",
                        preferredStyle: .alert
                    )
                    let confirmButton = UIAlertAction(title: "확인", style: .default) { _ in
                        Task { await self.loadCurrentUser() }
                    }
                    successAlert.addAction(confirmButton)
                    self.present(successAlert, animated: true)
                } catch {
                    print("가족 탈퇴 실패: \(error.localizedDescription)")
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        leaveFamilyAlert.addAction(okButton)
        leaveFamilyAlert.addAction(cancelButton)
        
        present(leaveFamilyAlert, animated: true)
    }
    
    private func handleProfileEdit() {
        // 로그인은 되어있지만 현재 사용자 정보 없는 경우
        if Auth.auth().currentUser != nil && currentUser == nil {
            showErrorAlert(message: "네트워크 상태를 확인하고 다시 시도해주세요.")
            return
        }
        
        guard let _ = currentUser else {
            print("사용자 정보가 없습니다.")
            return
        }
        
        // 사용자 정보 있는 경우
        let profileEditViewModel = ProfileEditViewModel()
        let profileEditViewController = ProfileEditViewController(
            viewModel: profileEditViewModel
        )
        
        navigationController?.pushViewController(profileEditViewController, animated: true)
    }
    
    private func handleNotificationSetting() {
        let notificationSettingViewModel = NotificationSettingViewModel()
        let notificationSettingViewController = NotificationSettingViewController(
            viewModel: notificationSettingViewModel
        )
        
        notificationSettingViewController.title = "알림"
        notificationSettingViewController.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(notificationSettingViewController, animated: true)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    /// 로딩 인디케이터 표시 (태그를 사용하여 중복 방지)
    private func showLoading() {
        // 이미 표시 중이라면 무시
        if let _ = view.viewWithTag(999) { return }
        
        // 배경 뷰 생성 (반투명 어두운 배경)
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.tag = 999
        
        // 인디케이터 생성
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = backgroundView.center
        indicator.startAnimating()
        
        backgroundView.addSubview(indicator)
        view.addSubview(backgroundView)
    }
    
    /// 로딩 인디케이터 제거
    private func hideLoading() {
        if let backgroundView = view.viewWithTag(999) {
            backgroundView.removeFromSuperview()
        }
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].section.title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "settingCell",
            for: indexPath
        )
        let sectionData = dataSource[indexPath.section]
        let item = sectionData.items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        
        switch item {
            case .appVersion:
                content.secondaryText = viewModel.fullVersionString
                cell.accessoryType = .none
                cell.selectionStyle = .none
            case .leaveFamily, .logout, .deleteAccount:
                content.textProperties.color = .systemRed
                cell.accessoryType = .none
            default:
                cell.accessoryType = .disclosureIndicator
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    public func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionData = dataSource[indexPath.section]
        let item = sectionData.items[indexPath.row]
        
        switch item {
            case .editProfile:
                handleProfileEdit()
            case .manageFamily:
                handleManageFamily()
            case .leaveFamily:
                handleLeaveFamily()
            case .logout:
                handleLogout()
            case .deleteAccount:
                handleDeleteAccount()
            case .notifications:
                handleNotificationSetting()
            default:
                print("\(item.title) 선택됨")
        }
    }
}


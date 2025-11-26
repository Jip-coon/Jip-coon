//
//  SettingViewController.swift
//  Feature
//
//  Created by 심관혁 on 10/29/25.
//

import Core
import UI
import UIKit
import FirebaseAuth

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
            return [.logout, .deleteAccount]
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
        case .logout: return "로그아웃"
        case .deleteAccount: return "회원 탈퇴"
        }
    }
}

public final class SettingViewController: UIViewController {

    private let authService = AuthService()
    private let userService = FirebaseUserService()

    // 현재 사용자 정보
    private var currentUser: Core.User?

    // 앱 버전
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"


    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView
            .register(
                UITableViewCell.self,
                forCellReuseIdentifier: "settingCell"
            )
        return tableView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadCurrentUser()
    }

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

    private func loadCurrentUser() {
        Task {
            do {
                currentUser = try await userService.getCurrentUser()
                if currentUser == nil { //TODO: - FireStore에 정보 없음 문제
                    print(
                        "Firebase Auth UID: \(Auth.auth().currentUser?.uid ?? "없음")"
                    )
                    print("이메일: \(Auth.auth().currentUser?.email ?? "없음")")
                }
                tableView.reloadData()
            } catch {
                print("사용자 정보 로드 실패: \(error.localizedDescription)")
                print(
                    "Firebase Auth 상태: \(Auth.auth().currentUser != nil ? "로그인됨" : "로그인되지 않음")"
                )
                // 기본적으로 자녀 권한으로 처리
                tableView.reloadData()
            }
        }
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
                    try self.authService.signOut()
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

    private func handleDeleteAccount() {
        let deleteAccountAlert = UIAlertController(
            title: "회원탈퇴",
            message: "회원탈퇴하시겠습니까?",
            preferredStyle: .alert
        )
        let okButton = UIAlertAction(title: "회원탈퇴", style: .destructive) { _ in
            Task {
                do {
                    try await self.authService.deleteAccount()
                    NotificationCenter.default
                        .post(
                            name: NSNotification.Name("LogoutSuccess"),
                            object: nil
                        )
                } catch {
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
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        let allSections = SettingSection.allCases
        // 부모인 경우에만 familyManage 섹션 포함
        if currentUser?.isParent == true {
            return allSections.count
        } else {
            return allSections.count - 1 // familyManage 섹션 제외
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let actualSection = getActualSection(for: section)
        return actualSection.items.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let actualSection = getActualSection(for: section)
        return actualSection.title
    }

    private func getActualSection(for section: Int) -> SettingSection {
        let allSections = SettingSection.allCases

        if currentUser?.isParent == true {
            return allSections[section]
        } else {
            // 부모가 아닌 경우 familyManage 섹션을 건너뜀
            let nonAdminSections = allSections.filter { $0 != .familyManage }
            return nonAdminSections[section]
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "settingCell",
            for: indexPath
        )
        let actualSection = getActualSection(for: indexPath.section)
        let item = actualSection.items[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.title

        switch item {
        case .appVersion:
            content.secondaryText = "\(appVersion).\(buildNumber)"
            cell.accessoryType = .none
            cell.selectionStyle = .none
        case .logout, .deleteAccount:
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
        let actualSection = getActualSection(for: indexPath.section)
        let item = actualSection.items[indexPath.row]

        switch item {
        case .logout:
            handleLogout()
        case .deleteAccount:
            handleDeleteAccount()
        case .appVersion:
            break
        default:
            print("\(item.title) 선택됨")
        }
    }
}


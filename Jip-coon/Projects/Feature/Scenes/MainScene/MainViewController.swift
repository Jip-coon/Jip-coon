//
//  MainViewController.swift
//  Feature
//
//  Created by 예슬 on 8/18/25.
//

import UIKit
import FirebaseFirestore
import UI
import Core

public class MainViewController: UIViewController {
  let db = Firestore.firestore()
  private let authService = AuthService()

    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "MainView"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    // 로그아웃 버튼 (테스트용)
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃 (테스트)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    // UIColor 테스트용 View
    let square: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainOrange
        return view
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupLogoutButton()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        Task {
            await addData()
            await readData()
        }
    }

    func setupView() {
        view.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        // 로그아웃 버튼 추가
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        // UIColor 테스트
        view.addSubview(square)
        square.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // 로그아웃 버튼 레이아웃
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),

            // UIColor 테스트
            square.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20),
            square.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            square.widthAnchor.constraint(equalToConstant: 100),
            square.heightAnchor.constraint(equalToConstant: 100)

        ])
    }
    
    func addData() async {
        // Add a new document with a generated ID
        do {
          let ref = try await db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
          ])
          print("Document added with ID: \(ref.documentID)")
        } catch {
          print("Error adding document: \(error)")
        }
    }
    
    func readData() async {
        do {
          let snapshot = try await db.collection("users").getDocuments()
          for document in snapshot.documents {
            print("\(document.documentID) => \(document.data())")
          }
        } catch {
          print("Error getting documents: \(error)")
        }
    }
    
    private func setupLogoutButton() {
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    @objc private func logoutButtonTapped() {
        do {
            try authService.signOut()
            print("로그아웃 성공")
            
            // 로그아웃 성공 알림 전송
            NotificationCenter.default.post(name: NSNotification.Name("LogoutSuccess"), object: nil)
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
            
            // 에러 알림 표시
            let alert = UIAlertController(title: "로그아웃 실패", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }

}

#Preview {
    MainViewController()
}

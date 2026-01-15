//
//  ForgotPasswordViewController.swift
//  Feature
//
//  Created by 예슬 on 1/15/26.
//

import Combine
import UI
import UIKit

final class ForgotPasswordViewController: UIViewController {
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "가입하신 이메일을 입력하시면 \n비밀번호 재설정 링크를 보내드립니다."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .textGray
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .textGray
        textField.setPlaceholder()
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftPadding()
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        return textField
    }()
    
    private let sendMailButton: UIButton = {
        let button = UIButton()
        button.setTitle("재설정 메일 보내기", for: .normal)
        button.setTitleColor(.backgroundWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .mainOrange
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.15
        button.layer.cornerRadius = 15
        button.addTarget(
            self,
            action: #selector(sendMailButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        // 에러 메시지 표시
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showAlert(title: "오류", message: error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        sendMailButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(descriptionLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendMailButton)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            sendMailButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            sendMailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendMailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendMailButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc private func sendMailButtonTapped() {
        Task {
            let isSuccess = await viewModel.sendPasswordResetEmail(email: emailTextField.text ?? "")
            
            if isSuccess {
                showSuccessAlert()
            }
        }
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
    
    private func showSuccessAlert() {
        let successMessage = """
        비밀번호 재설정 메일을 보냈습니다.
                    
        메일이 오지 않는다면 입력하신 이메일이 가입 시 사용한 정보와 일치하는지 확인해 주세요.
        (스팸 메일함도 확인 부탁드립니다.)
        """
        
        let alert = UIAlertController(
            title: "알림",
            message: successMessage,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "확인",
            style: .default
        ) { [weak self] _ in
            self?.dismiss(animated: true) // 확인 누르면 모달 닫기
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

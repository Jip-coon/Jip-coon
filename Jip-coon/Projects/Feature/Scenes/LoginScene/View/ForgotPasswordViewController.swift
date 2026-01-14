//
//  ForgotPasswordViewController.swift
//  Feature
//
//  Created by 예슬 on 1/15/26.
//

import UI
import UIKit

final class ForgotPasswordViewController: UIViewController {
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
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
}

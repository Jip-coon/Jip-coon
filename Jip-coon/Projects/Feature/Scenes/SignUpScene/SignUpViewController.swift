//
//  SignUpViewController.swift
//  Feature
//
//  Created by 예슬 on 8/27/25.
//

import UIKit
import UI

public final class SignUpViewController: UIViewController {
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.textColor = .mainOrange
        label.font = .systemFont(ofSize: 48, weight: .bold)
        return label
    }()
    
    private let emailEnterLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일을 입력해 주세요"
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "jipcoon@example.com"
        textField.setPlaceholder()
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftPadding()
        return textField
    }()
    
    private let passwordEnterLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 입력해 주세요"
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.backgroundColor = .backgroundWhite
        
        [signUpLabel,
         emailEnterLabel,
         emailTextField,
         passwordEnterLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [signUpLabel,
         emailEnterLabel,
         emailTextField,
         passwordEnterLabel
        ].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            signUpLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 73),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailEnterLabel.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 62),
            emailEnterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            emailTextField.topAnchor.constraint(equalTo: emailEnterLabel.bottomAnchor, constant: 4),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            passwordEnterLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 41),
            passwordEnterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
    
}

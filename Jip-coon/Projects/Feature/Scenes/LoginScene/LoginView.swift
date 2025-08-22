//
//  LoginView.swift
//  Feature
//
//  Created by 예슬 on 8/23/25.
//

import UIKit
import UI

final class LoginView: UIView {
    let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let loginTitle: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .mainOrange
        return label
    }()
    
    lazy var emailTextField: UITextField = makeTextField(placeholder: "이메일")
    lazy var passwordTextField: UITextField = makeTextField(placeholder: "비밀번호")
    lazy var findIdButton: UIButton = makeUnderlineButton(title: "아이디 찾기")
    lazy var findPasswordButton: UIButton = makeUnderlineButton(title: "비밀번호 찾기")
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.backgroundWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .mainOrange
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.15
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let noAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "계정이 없으신가요?"
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let signUpButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "회원가입"
        config.baseForegroundColor = .secondaryOrange
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .bold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let loginWithLabel: UILabel = {
        let label = UILabel()
        label.text = "다음으로 로그인"
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let googleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "GoogleLogin", in: uiBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = .backgroundWhite
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [loginTitle,
         emailTextField,
         passwordTextField,
         findIdButton,
         findPasswordButton,
         loginButton,
         noAccountLabel,
         signUpButton,
         loginWithLabel,
         googleLoginButton,
         appleLoginButton
        ].forEach(contentView.addSubview)
        
        [scrollView,
         contentView,
         loginTitle,
         emailTextField,
         passwordTextField,
         findIdButton,
         findPasswordButton,
         loginButton,
         noAccountLabel,
         signUpButton,
         loginWithLabel,
         googleLoginButton,
         appleLoginButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setUpConstrains() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            loginTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 91),
            
            emailTextField.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 80),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            findIdButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            findIdButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -14),
            
            findPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            findPasswordButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 14),
            
            loginButton.topAnchor.constraint(equalTo: findIdButton.bottomAnchor, constant: 44),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 56),
            
            noAccountLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 17),
            noAccountLabel.leadingAnchor.constraint(equalTo: findIdButton.leadingAnchor, constant: -10),
            
            signUpButton.topAnchor.constraint(equalTo: noAccountLabel.topAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: noAccountLabel.trailingAnchor, constant: 18),
            
            loginWithLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 70),
            loginWithLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            googleLoginButton.topAnchor.constraint(equalTo: loginWithLabel.bottomAnchor, constant: 14),
            googleLoginButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -26),
            googleLoginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            appleLoginButton.topAnchor.constraint(equalTo: loginWithLabel.bottomAnchor, constant: 14),
            appleLoginButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 26)
        ])
    }
    
    private func makeTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.setPlaceholder()
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftPadding()
        return textField
    }
    
    private func makeUnderlineButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.textGray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
}

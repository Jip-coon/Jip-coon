//
//  LoginViewController.swift
//  Feature
//
//  Created by 예슬 on 8/21/25.
//

import UIKit
import UI

public class LoginViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let loginTitle: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .mainOrange
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일"
        textField.setPlaceholder()
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftPadding()
        return textField
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpButtonAction()
        hideKeyboardWhenTappedAround()
    }
    
    private func setUpView() {
        view.backgroundColor = .backgroundWhite
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [loginTitle,
         emailTextField,
         appleLoginButton
        ].forEach(contentView.addSubview)

        
        [scrollView,
         contentView,
         loginTitle,
         emailTextField,
         appleLoginButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            loginTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 91),
            
            emailTextField.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 134),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            appleLoginButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 706),
            appleLoginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            appleLoginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -131)
        ])
    }
    
    private func setUpButtonAction() {
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    
    @objc private func appleLoginTapped() {
        print("apple login button tapped")
    }
    
    // 키보드 숨기기
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

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
    private var activeField: UIView?
    private var savedContentOffset: CGPoint?
    
    private let loginTitle: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .mainOrange
        return label
    }()
    
    private lazy var emailTextField: UITextField = makeTextField(placeholder: "이메일")
    private lazy var passwordTextField: UITextField = makeTextField(placeholder: "비밀번호")
    private lazy var findIdButton: UIButton = makeUnderlineButton(title: "아이디 찾기")
    private lazy var findPasswordButton: UIButton = makeUnderlineButton(title: "비밀번호 찾기")
    
    private let loginButton: UIButton = {
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
    
    private let signUpButton: UIButton = {
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
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpButtonAction()
        setUpDelegate()
        setupKeyboardObservers()
        hideKeyboardWhenTappedAround()
    }
    
    private func setUpView() {
        view.backgroundColor = .backgroundWhite
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [loginTitle,
         emailTextField,
         passwordTextField,
         findIdButton,
         findPasswordButton,
         loginButton,
         noAccountLabel,
         signUpButton,
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
            
            appleLoginButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 706),
            appleLoginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            appleLoginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -131)
        ])
    }
    
    private func setUpDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setUpButtonAction() {
        findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    
    @objc private func findIdButtonTapped() {
        print("find id button tapped")
    }
    
    @objc private func findPasswordButtonTapped() {
        print("find password button tapped")
    }
    
    @objc private func loginButtonTapped() {
        print("login button tapped")
    }
    
    @objc private func signUpButtonTapped() {
        print("sign up button tapped")
    }
    
    @objc private func appleLoginTapped() {
        print("apple login button tapped")
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
    
    // 키보드 숨기기
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 키보드에 화면 가릴 경우 뷰 이동
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, // 키보드가 나타날 때 발생하는 알림
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // 키보드 크기 가져와서 뷰 이동
    @objc private func keyboardWillShow(_ notification: Notification) {
        if savedContentOffset == nil {
            savedContentOffset = scrollView.contentOffset
        }
        
        guard
            let userInfo = notification.userInfo,   // 키보드가 나타날 때 최종 위치와 크기(frame) 를 userInfo에 담아줌
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue    // 최종적으로 나타나는 키보드의 frame (화면 좌표계)
        else { return }
        
        let keyboardHeight = keyboardFrame.height
        let minDistance = 50.0
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + minDistance, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        if let activeField = activeField {
            let rect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        if let saved = savedContentOffset {
            scrollView.setContentOffset(saved, animated: true)
            savedContentOffset = nil
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if activeField === textField {
            activeField = nil
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

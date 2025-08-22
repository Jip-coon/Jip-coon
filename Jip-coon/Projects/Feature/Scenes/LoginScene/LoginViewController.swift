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
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일"
        textField.setPlaceholder()
        textField.keyboardType = .emailAddress
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftPadding()
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호"
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
         appleLoginButton
        ].forEach(contentView.addSubview)
        
        
        [scrollView,
         contentView,
         loginTitle,
         emailTextField,
         passwordTextField,
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

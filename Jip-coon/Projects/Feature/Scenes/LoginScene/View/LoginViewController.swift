//
//  LoginViewController.swift
//  Feature
//
//  Created by 예슬 on 8/21/25.
//

import UIKit
import UI

public class LoginViewController: UIViewController {
    private var activeField: UIView?
    private var savedContentOffset: CGPoint?
    private let loginView = LoginView()
    
    override public func loadView() {
        view = loginView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonAction()
        setUpDelegate()
        setupKeyboardObservers()
        hideKeyboardWhenTappedAround()
    }
    
    private func setUpDelegate() {
        loginView.emailTextField.delegate = self
        loginView.passwordTextField.delegate = self
    }
    
    private func setUpButtonAction() {
        loginView.findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        loginView.findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginView.googleLoginButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        loginView.appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    // MARK: - Button Action
    
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
    
    @objc private func googleLoginTapped() {
        print("google login button tapped")
    }
    
    @objc private func appleLoginTapped() {
        print("apple login button tapped")
    }
    // MARK: - Keyboard
    
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
            savedContentOffset = loginView.scrollView.contentOffset
        }
        
        guard
            let userInfo = notification.userInfo,   // 키보드가 나타날 때 최종 위치와 크기(frame) 를 userInfo에 담아줌
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue    // 최종적으로 나타나는 키보드의 frame (화면 좌표계)
        else { return }
        
        let keyboardHeight = keyboardFrame.height
        let minDistance = 50.0
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + minDistance, right: 0)
        loginView.scrollView.contentInset = insets
        loginView.scrollView.scrollIndicatorInsets = insets
        
        if let activeField = activeField {
            let rect = activeField.convert(activeField.bounds, to: loginView.scrollView)
            loginView.scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        loginView.scrollView.contentInset = contentInset
        loginView.scrollView.scrollIndicatorInsets = contentInset
        
        if let saved = savedContentOffset {
            loginView.scrollView.setContentOffset(saved, animated: true)
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

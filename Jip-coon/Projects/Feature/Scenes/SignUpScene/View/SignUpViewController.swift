//
//  SignUpViewController.swift
//  Feature
//
//  Created by 예슬 on 8/27/25.
//

import Combine
import Core
import UI
import UIKit

public final class SignUpViewController: UIViewController {
    private let viewModel = SignUpViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var activeField: UITextField?
    
    // MARK: - View
    
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
    
    private let emailInvalidLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 형식이 올바르지 않습니다"
        label.textColor = .textRed
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
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
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    private let passwordEnterLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 입력해 주세요"
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "6자리 이상 입력해 주세요"
        textField.setPlaceholder()
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 15
        textField.leftPadding()
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.textContentType = .oneTimeCode
        textField.spellCheckingType = .no
        return textField
    }()
    
    private let passwordInvalidLabel: UILabel = {
        let label = UILabel()
        label.text = "6자리 이상 입력해 주세요"
        label.textColor = .textRed
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원 가입", for: .normal)
        button.setTitleColor(.backgroundWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .mainOrange
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.15
        button.layer.cornerRadius = 15
        return button
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupTargets()
        setupDelegate()
        hideKeyboardWhenTappedAround()
        setupKeyboardObservers()
    }
    
    // MARK: - Method
    
    private func setupView() {
        view.backgroundColor = .backgroundWhite
        
        [signUpLabel,
         emailEnterLabel,
         emailTextField,
         passwordEnterLabel,
         passwordTextField,
         emailInvalidLabel,
         passwordInvalidLabel,
         signUpButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [signUpLabel,
         emailEnterLabel,
         emailTextField,
         passwordEnterLabel,
         passwordTextField,
         emailInvalidLabel,
         passwordInvalidLabel,
         signUpButton
        ].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
[
            signUpLabel.topAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 38
                ),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailEnterLabel.topAnchor
                .constraint(equalTo: signUpLabel.bottomAnchor, constant: 62),
            emailEnterLabel.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            
            emailTextField.topAnchor
                .constraint(equalTo: emailEnterLabel.bottomAnchor, constant: 4),
            emailTextField.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            emailTextField.trailingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20
                ),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            passwordEnterLabel.topAnchor
                .constraint(equalTo: emailTextField.bottomAnchor, constant: 41),
            passwordEnterLabel.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            
            passwordTextField.topAnchor
                .constraint(
                    equalTo: passwordEnterLabel.bottomAnchor,
                    constant: 4
                ),
            passwordTextField.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            passwordTextField.trailingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20
                ),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            emailInvalidLabel.topAnchor
                .constraint(equalTo: emailTextField.bottomAnchor, constant: 4),
            emailInvalidLabel.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            
            passwordInvalidLabel.topAnchor
                .constraint(
                    equalTo: passwordTextField.bottomAnchor,
                    constant: 4
                ),
            passwordInvalidLabel.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            
            signUpButton.topAnchor
                .constraint(
                    equalTo: passwordTextField.bottomAnchor,
                    constant: 75
                ),
            signUpButton.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            signUpButton.trailingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20
                ),
            signUpButton.heightAnchor.constraint(equalToConstant: 56)
]
        )
    }
    
    private func bindViewModel() {
        viewModel.$isEmailValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.emailInvalidLabel.isHidden = isValid
            }
            .store(in: &cancellables)
        
        viewModel.$isPasswordValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.passwordInvalidLabel.isHidden = isValid
            }
            .store(in: &cancellables)
        
        viewModel.$isSignUpEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.signUpButton.isEnabled = isEnabled
                self?.signUpButton.backgroundColor = isEnabled ? .mainOrange : .textFieldStroke
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.signUpButton.isEnabled = !isLoading && self?.viewModel.isSignUpEnabled == true
                // 로딩 중일 때는 버튼 비활성화
                if isLoading {
                    self?.signUpButton.setTitle("회원 가입 중...", for: .disabled)
                } else {
                    self?.signUpButton.setTitle("회원 가입", for: .normal)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showAlert(title: "회원가입 실패", message: errorMessage)
                    print("회원가입 에러: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTargets() {
        emailTextField
            .addTarget(
                self,
                action: #selector(emailChanged),
                for: .editingChanged
            )
        passwordTextField
            .addTarget(
                self,
                action: #selector(passwordChanged),
                for: .editingChanged
            )
        signUpButton
            .addTarget(
                self,
                action: #selector(signUpTapped),
                for: .touchUpInside
            )
    }
    
    private func setupDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc private func emailChanged() {
        viewModel.email = emailTextField.text ?? ""
    }
    
    @objc private func passwordChanged() {
        viewModel.password = passwordTextField.text ?? ""
    }
    
    @objc private func signUpTapped() {
        Task {
            await viewModel.performSignUp()
            navigationController?.popViewController(animated: true)
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
    
    // MARK: - Keyboard
    
    // 키보드 숨기기
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (
                userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            )?.cgRectValue,
            let activeField = activeField
        else { return }
        
        let keyboardMinY = keyboardFrame.minY   // 키보드의 상단 Y좌표
        let activeFieldFrame = activeField.convert(
            activeField.bounds,
            to: view
        )    // 현재 텍스트필드의 화면(view 기준) 좌표
        let minDistance = 50.0
        let activeFieldMaxY = activeFieldFrame.maxY + minDistance    // 텍스트필드의 맨 아래 좌표 + 여유 공간(50px)
        
        if activeFieldMaxY > keyboardMinY {
            let overlap = activeFieldMaxY - keyboardMinY
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(
                    translationX: 0,
                    y: -overlap
                )
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            view.endEditing(true)
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if activeField == textField {
            activeField = nil
        }
    }
}

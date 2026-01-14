//
//  LoginViewController.swift
//  Feature
//
//  Created by 예슬 on 8/21/25.
//

import Combine
import UI
import UIKit

public class LoginViewController: UIViewController {
    private let loginView = LoginView()
    
    private var activeField: UIView?
    private var savedContentOffset: CGPoint?
    
    private let viewModel: LoginViewModel
    private let appleLoginViewModel: AppleLoginViewModel
    private let googleLoginViewModel: GoogleLoginViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        viewModel: LoginViewModel,
        appleLoginViewModel: AppleLoginViewModel,
        googleLoginViewModel: GoogleLoginViewModel
    ) {
        self.viewModel = viewModel
        self.appleLoginViewModel = appleLoginViewModel
        self.googleLoginViewModel = googleLoginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override public func loadView() {
        view = loginView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonAction()
        setUpDelegate()
        setupKeyboardObservers()
        hideKeyboardWhenTappedAround()
        bindViewModel()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - setup
    
    private func setUpDelegate() {
        loginView.emailTextField.delegate = self
        loginView.passwordTextField.delegate = self
    }
    
    private func setUpButtonAction() {
        loginView.findPasswordButton
            .addTarget(
                self,
                action: #selector(findPasswordButtonTapped),
                for: .touchUpInside
            )
        loginView.loginButton
            .addTarget(
                self,
                action: #selector(loginButtonTapped),
                for: .touchUpInside
            )
        loginView.signUpButton
            .addTarget(
                self,
                action: #selector(signUpButtonTapped),
                for: .touchUpInside
            )
        loginView.googleLoginButton
            .addTarget(
                self,
                action: #selector(googleLoginTapped),
                for: .touchUpInside
            )
        loginView.appleLoginButton
            .addTarget(
                self,
                action: #selector(appleLoginTapped),
                for: .touchUpInside
            )
    }
    // MARK: - Button Action
    
    @objc private func findIdButtonTapped() {
        print("find id button tapped")
        // TODO: - ID 찾기
    }
    
    @objc private func findPasswordButtonTapped() {
        print("find password button tapped")
        // TODO: - 비밀번호 찾기
    }
    
    @objc private func loginButtonTapped() {
        // 입력 필드에서 이메일과 비밀번호 가져오기
        viewModel.email = loginView.emailTextField.text ?? ""
        viewModel.password = loginView.passwordTextField.text ?? ""
        
        // 로그인 실행
        Task {
            await viewModel.signIn()
        }
    }
    
    @objc private func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        navigationController?
            .pushViewController(signUpViewController, animated: true)
    }
    
    @objc private func googleLoginTapped() {
        print("google login button tapped")
        googleLoginViewModel.signIn(presentingVC: self)
    }
    
    @objc private func appleLoginTapped() {
        print("apple login button tapped")
        appleLoginViewModel.startSignInWithAppleFlow()
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
            let keyboardFrame = (
                userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            )?.cgRectValue    // 최종적으로 나타나는 키보드의 frame (화면 좌표계)
        else { return }
        
        let keyboardHeight = keyboardFrame.height
        let minDistance = 50.0
        let insets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardHeight + minDistance,
            right: 0
        )
        loginView.scrollView.contentInset = insets
        loginView.scrollView.scrollIndicatorInsets = insets
        
        if let activeField = activeField {
            let rect = activeField.convert(
                activeField.bounds,
                to: loginView.scrollView
            )
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
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        // 로그인 성공 시 메인 화면으로 이동
        viewModel.loginSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigateToMainScreen()
            }
            .store(in: &cancellables)
        
        // 에러 메시지 표시
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showErrorAlert(message: error)
                }
            }
            .store(in: &cancellables)
        
        // 로딩 상태 처리
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        appleLoginViewModel.loginSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigateToMainScreen()
            }
            .store(in: &cancellables)
        
        googleLoginViewModel.loginSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigateToMainScreen()
            }
            .store(in: &cancellables)
    }
    
    private func navigateToMainScreen() {
        // 로그인 성공 알림 전송
        NotificationCenter.default
            .post(name: NSNotification.Name("LoginSuccess"), object: nil)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        loginView.loginButton.isEnabled = !isLoading
        loginView.loginButton
            .setTitle(isLoading ? "로그인 중..." : "로그인", for: .normal)
    }
}

// MARK: - TextFieldDelegate

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
        if textField == loginView.emailTextField {
            loginView.passwordTextField.becomeFirstResponder()
        } else if textField == loginView.passwordTextField {
            view.endEditing(true)
        }
        return true
    }
}

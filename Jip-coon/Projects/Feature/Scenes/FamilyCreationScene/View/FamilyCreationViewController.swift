//
//  FamilyCreationViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/15/26.
//

import Core
import UI
import UIKit

/// 가족 생성 화면을 담당하는 뷰 컨트롤러
/// - 가족 이름 입력과 초대코드 생성을 통합하여 제공
/// - FirebaseFamilyService를 활용한 실제 가족 생성 기능 구현
public class FamilyCreationViewController: UIViewController {
    
    // MARK: - Properties
    
    private let familyService: FamilyServiceProtocol
    private let userService: UserServiceProtocol
    private var currentUser: User?
    
    public var onFamilyCreated: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.backgroundWhite
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundWhite
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🏠 우리 가족 만들기"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.textGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "가족 이름을 입력하고 초대코드를 공유하세요"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var familyNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "가족 이름을 입력하세요"
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.textColor = UIColor.textGray
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가족 생성하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.mainOrange
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var inviteCodeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mainOrange.cgColor
        view.isHidden = true
        return view
    }()
    
    private lazy var inviteCodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "초대코드"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.mainOrange
        return label
    }()
    
    private lazy var inviteCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.mainOrange
        label.textAlignment = .center
        return label
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📤 공유하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.mainOrange
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor.mainOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor.mainOrange
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    
    public init(
        familyService: FamilyServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.familyService = familyService
        self.userService = userService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupKeyboardNotifications()
        loadCurrentUser()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.backgroundWhite
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, subtitleLabel, familyNameTextField, createButton,
         inviteCodeView, doneButton, activityIndicator].forEach {
            contentView.addSubview($0)
        }
        
        inviteCodeView.addSubview(inviteCodeTitleLabel)
        inviteCodeView.addSubview(inviteCodeLabel)
        inviteCodeView.addSubview(shareButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [scrollView, contentView, titleLabel, subtitleLabel, familyNameTextField,
         createButton, inviteCodeView, doneButton, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // TextField
            familyNameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            familyNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            familyNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            familyNameTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Create Button
            createButton.topAnchor.constraint(equalTo: familyNameTextField.bottomAnchor, constant: 24),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Invite Code View
            inviteCodeView.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 40),
            inviteCodeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            inviteCodeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            inviteCodeView.heightAnchor.constraint(equalToConstant: 160),
            
            // Done Button
            doneButton.topAnchor.constraint(equalTo: inviteCodeView.bottomAnchor, constant: 40),
            doneButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
        
        // Invite Code View 내부 레이아웃
        [inviteCodeTitleLabel, inviteCodeLabel, shareButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            inviteCodeTitleLabel.topAnchor.constraint(equalTo: inviteCodeView.topAnchor, constant: 16),
            inviteCodeTitleLabel.centerXAnchor.constraint(equalTo: inviteCodeView.centerXAnchor),
            
            inviteCodeLabel.topAnchor.constraint(equalTo: inviteCodeTitleLabel.bottomAnchor, constant: 8),
            inviteCodeLabel.centerXAnchor.constraint(equalTo: inviteCodeView.centerXAnchor),
            
            shareButton.topAnchor.constraint(equalTo: inviteCodeLabel.bottomAnchor, constant: 16),
            shareButton.leadingAnchor.constraint(equalTo: inviteCodeView.leadingAnchor, constant: 24),
            shareButton.trailingAnchor.constraint(equalTo: inviteCodeView.trailingAnchor, constant: -24),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadCurrentUser() {
        Task {
            do {
                self.currentUser = try await userService.getCurrentUser()
            } catch {
                print("사용자 정보 로드 실패: \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func createButtonTapped() {
        guard let familyName = familyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !familyName.isEmpty else {
            showAlert(title: "알림", message: "가족 이름을 입력해주세요.")
            return
        }
        
        guard let user = currentUser else {
            showAlert(title: "오류", message: "사용자 정보를 불러올 수 없습니다.")
            return
        }
        
        createFamily(name: familyName, createdBy: user.id)
    }
    
    @objc private func shareButtonTapped() {
        guard let inviteCode = inviteCodeLabel.text else { return }
        
        let shareText = "우리 가족에 참여하세요! 초대코드: \(inviteCode)"
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
    
    @objc private func doneButtonTapped() {
        onFamilyCreated?()
        dismiss(animated: true)
    }
    
    // MARK: - Family Creation
    
    private func createFamily(name: String, createdBy: String) {
        // UI 상태 변경
        setLoadingState(true)
        
        Task {
            do {
                let createdFamily = try await familyService.createFamily(name: name, createdBy: createdBy)
                
                await MainActor.run {
                    showInviteCode(createdFamily.inviteCode)
                    setLoadingState(false)
                }
            } catch {
                await MainActor.run {
                    setLoadingState(false)
                    showAlert(title: "오류", message: "가족 생성에 실패했습니다. 다시 시도해주세요.")
                }
                print("가족 생성 실패: \(error)")
            }
        }
    }
    
    private func showInviteCode(_ code: String) {
        inviteCodeLabel.text = code
        inviteCodeView.isHidden = false
        doneButton.isHidden = false
        createButton.isHidden = true
        familyNameTextField.isEnabled = false
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            createButton.setTitle("", for: .normal)
            createButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            createButton.setTitle("가족 생성하기", for: .normal)
            createButton.isEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
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
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - UITextFieldDelegate

extension FamilyCreationViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

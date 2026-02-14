//
//  FamilyCreationViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/15/26.
//

import Core
import UI
import UIKit

/// 가족 생성/참여 화면을 담당하는 뷰 컨트롤러
/// - 가족 생성: 이름 입력과 초대코드 생성
/// - 가족 참여: 초대코드 입력으로 기존 가족 참여
/// - FirebaseFamilyService를 활용한 실제 기능 구현
final class FamilyCreationViewController: UIViewController {
    
    // MARK: - Mode
    
    private enum Mode: Int {
        case create = 0
        case join = 1
        
        var title: String {
            switch self {
                case .create: return "가족 만들기"
                case .join: return "가족 참여하기"
            }
        }
        
        var subtitle: String {
            switch self {
                case .create: return "가족 이름을 입력하고 초대코드를 공유하세요"
                case .join: return "초대코드를 입력하여 가족에 참여하세요"
            }
        }
    }
    
    private var currentMode: Mode = .create {
        didSet {
            updateUIForCurrentMode()
        }
    }
    
    // MARK: - Properties
    
    private let familyService: FamilyServiceProtocol
    private let userService: UserServiceProtocol
    private var currentUser: User?
    let components = FamilyCreationComponents()
    
    var onFamilyCreated: (() -> Void)?
    
    
    // MARK: - Initialization
    
    init(
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        components.delegate = self
        components.familyNameTextField.delegate = self
        components.inviteCodeTextField.delegate = self
        setupNavigationBar()
        setupUI()
        setupKeyboardNotifications()
        updateUIForCurrentMode() // 초기 UI 상태 설정
        loadCurrentUser()
    }
    
    // MARK: - Navigation Bar Setup
    
    private func setupNavigationBar() {
        // 네비게이션 바 타이틀 설정
        title = "가족 만들기"
        
        // 닫기 버튼 추가
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = UIColor.textGray
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func updateUIForCurrentMode() {
        title = currentMode.title
        
        // 타이틀 텍스트 설정
        switch currentMode {
            case .create:
                components.titleLabel.text = "🏠 우리 가족 만들기"
            case .join:
                components.titleLabel.text = "🏠 우리 가족 참여하기"
        }
        
        components.subtitleLabel.text = currentMode.subtitle
        
        switch currentMode {
            case .create:
                components.familyNameTextField.isHidden = false
                components.inviteCodeTextField.isHidden = true
                components.createButton.isHidden = false
                components.joinButton.isHidden = true
                
                // 초대코드 뷰 숨김
                components.inviteCodeView.isHidden = true
                components.doneButton.isHidden = true
                
            case .join:
                components.familyNameTextField.isHidden = true
                components.inviteCodeTextField.isHidden = false
                components.createButton.isHidden = true
                components.joinButton.isHidden = false
                
                // 초대코드 뷰 숨김
                components.inviteCodeView.isHidden = true
                components.doneButton.isHidden = true
        }
        
        // 키보드 내리기
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.backgroundWhite
        
        view.addSubview(components.scrollView)
        components.scrollView.addSubview(components.contentView)
        
        [components.modeSegmentControl,
         components.titleLabel,
         components.subtitleLabel,
         components.familyNameTextField,
         components.inviteCodeTextField,
         components.createButton,
         components.joinButton,
         components.inviteCodeView,
         components.doneButton,
         components.activityIndicator
        ].forEach {
            components.contentView.addSubview($0)
        }
        
        components.inviteCodeView.addSubview(components.inviteCodeTitleLabel)
        components.inviteCodeView.addSubview(components.inviteCodeLabel)
        components.inviteCodeView.addSubview(components.shareButton)
        
        setupConstraints()
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
    
    private func createButtonTapped() {
        guard let familyName = components.familyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
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
    
    private func joinButtonTapped() {
        Task {
            await joinFamily()
        }
    }
    
    private func shareButtonTapped() {
        guard let inviteCode = components.inviteCodeLabel.text else { return }
        
        let shareText = "우리 가족에 참여하세요! 초대코드: \(inviteCode)"
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
    
    private func doneButtonTapped() {
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
    
    private func joinFamily() async {
        guard let inviteCode = components.inviteCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !inviteCode.isEmpty else {
            showAlert(title: "입력 오류", message: "초대코드를 입력해주세요.")
            return
        }
        
        guard inviteCode.count == 6, inviteCode.allSatisfy({ $0.isNumber }) else {
            showAlert(title: "입력 오류", message: "6자리 숫자 초대코드를 입력해주세요.")
            return
        }
        
        guard let currentUser = currentUser else {
            showAlert(title: "오류", message: "사용자 정보를 불러올 수 없습니다.")
            return
        }
        
        // UI 상태 변경
        setLoadingState(true)
        
        do {
            let joinedFamily = try await familyService.joinFamily(inviteCode: inviteCode, userId: currentUser.id)
            
            await MainActor.run {
                setLoadingState(false)
                let alert = UIAlertController(
                    title: "참여 완료",
                    message: "'\(joinedFamily.name)' 가족에 참여했습니다!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.onFamilyCreated?()
                    self?.dismiss(animated: true)
                })
                present(alert, animated: true)
            }
        } catch {
            await MainActor.run {
                setLoadingState(false)
                let errorMessage = (error as NSError).userInfo[NSLocalizedDescriptionKey] as? String ?? "가족 참여에 실패했습니다."
                showAlert(title: "참여 실패", message: errorMessage)
            }
            print("가족 참여 실패: \(error)")
        }
    }
    
    private func showInviteCode(_ code: String) {
        components.inviteCodeLabel.text = code
        components.inviteCodeView.isHidden = false
        components.doneButton.isHidden = false
        components.createButton.isHidden = true
        components.familyNameTextField.isEnabled = false
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            components.activityIndicator.startAnimating()
            components.familyNameTextField.isEnabled = false
            components.inviteCodeTextField.isEnabled = false
            components.createButton.setTitle("", for: .normal)
            components.createButton.isEnabled = false
            components.joinButton.setTitle("", for: .normal)
            components.joinButton.isEnabled = false
        } else {
            components.activityIndicator.stopAnimating()
            components.familyNameTextField.isEnabled = true
            components.inviteCodeTextField.isEnabled = true
            components.createButton.setTitle("가족 생성하기", for: .normal)
            components.createButton.isEnabled = true
            components.joinButton.setTitle("가족 참여하기", for: .normal)
            components.joinButton.isEnabled = true
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
        components.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        components.scrollView.scrollIndicatorInsets = components.scrollView.contentInset
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        components.scrollView.contentInset = .zero
        components.scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - FamilyCreationComponentsDelegate

extension FamilyCreationViewController: FamilyCreationComponentsDelegate {
    func didChangeMode(to index: Int) {
        currentMode = Mode(rawValue: index) ?? .create
    }
    
    func didTapCreateButton() {
        createButtonTapped()
    }
    
    func didTapJoinButton() {
        joinButtonTapped()
    }
    
    func didTapShareButton() {
        shareButtonTapped()
    }
    
    func didTapDoneButton() {
        doneButtonTapped()
    }
}

// MARK: - UITextFieldDelegate

extension FamilyCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

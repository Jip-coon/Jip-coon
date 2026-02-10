//
//  ProfileEditViewController.swift
//  Feature
//
//  Created by 예슬 on 11/25/25.
//

import Combine
import Core
import UI
import UIKit

final class ProfileEditViewController: UIViewController {
    private let viewModel: ProfileEditViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View
    
    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.layer.borderColor = UIColor.textFieldStroke.cgColor
        stackView.layer.borderWidth = 0.7
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = .white
        stackView.alignment = .leading
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 9, left: 14, bottom: 9, right: 14)
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .textGray
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        return textField
    }()
    
    private let emailInfoView: ProfileInfoView = {
        .init(title: "Email Address")
    }()
    
    private let familyInfoView: ProfileInfoView = {
        .init(title: "Family")
    }()
    
    private let profileInfoEditButton: UIButton = {
        let button = UIButton()
        button.setTitle("변경사항 저장", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 20, weight: .semibold)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(
        viewModel: ProfileEditViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAddTarget()
        hideKeyboardWhenTappedAround()
        dataBinding()
        nameTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - setupView
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "프로필 수정"
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(nameStackView)
        view.addSubview(emailInfoView)
        view.addSubview(familyInfoView)
        view.addSubview(profileInfoEditButton)
        
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(nameTextField)
        
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        emailInfoView.translatesAutoresizingMaskIntoConstraints = false
        familyInfoView.translatesAutoresizingMaskIntoConstraints = false
        profileInfoEditButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameStackView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 37),
            nameStackView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 20),
            nameStackView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailInfoView.topAnchor
                .constraint(equalTo: nameStackView.bottomAnchor, constant: 20),
            emailInfoView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 20),
            emailInfoView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -20),
            
            familyInfoView.topAnchor
                .constraint(equalTo: emailInfoView.bottomAnchor, constant: 20),
            familyInfoView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 20),
            familyInfoView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -20),
            
            profileInfoEditButton.topAnchor
                .constraint(equalTo: familyInfoView.bottomAnchor, constant: 50),
            profileInfoEditButton.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 20),
            profileInfoEditButton.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -20),
            profileInfoEditButton.heightAnchor.constraint(equalToConstant: 47),
        ])
    }
    
    // MARK: - Data Binding
    
    private func dataBinding() {
        viewModel.$familyName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.familyInfoView.updateInfo(name)
            }
            .store(in: &cancellables)
        
        viewModel.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.nameTextField.text = user.name
                self?.emailInfoView.updateInfo(user.email)
            }
            .store(in: &cancellables)
        
        viewModel.$isNameChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isChanged in
                self?.profileInfoEditButton.isEnabled = isChanged
                self?.profileInfoEditButton.isHidden = !isChanged
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    private func setupAddTarget() {
        profileInfoEditButton
            .addTarget(
                self,
                action: #selector(profileInfoEditButtonTapped),
                for: .touchUpInside
            )
        nameTextField
            .addTarget(
                self,
                action: #selector(nameTextFieldDidChange(_:)),
                for: .editingChanged
            )
    }
    
    @objc private func profileInfoEditButtonTapped() {
        view.endEditing(true)
        
        let newName = nameTextField.text ?? viewModel.user?.name ?? ""
        Task {
            await viewModel.updateProfileName(newName: newName)
        }
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        viewModel.enteredName = textField.text ?? ""
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TextFieldDelegate

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

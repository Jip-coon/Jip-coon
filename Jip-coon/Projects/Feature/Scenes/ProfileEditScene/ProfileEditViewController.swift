//
//  ProfileEditViewController.swift
//  Feature
//
//  Created by 예슬 on 11/25/25.
//

import Core
import UI
import UIKit

final class ProfileEditViewController: UIViewController {
//    var currentUser: User
    
    // MARK: - View
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
        let iconImage = UIImage(systemName: "person.fill", withConfiguration: config)
        imageView.image = iconImage
        imageView.contentMode = .center
        imageView.tintColor = .textGray
        imageView.backgroundColor = .textFieldStroke
        return imageView
    }()
    
    private let profileImageEditButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .black
        button.contentMode = .center
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
        button.layer.masksToBounds = false
        return button
    }()
    
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Star", in: uiBundle, with: nil)
        return imageView
    }()
    
    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.text = "250"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
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
        textField.isUserInteractionEnabled = false
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
        button.setTitle("수정 하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 20, weight: .semibold)
        button.backgroundColor = .mainOrange
        button.layer.cornerRadius = 12
        return button
    }()
    
//    init(currentUser: User) {
//        self.currentUser = currentUser
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButtonActions()
        hideKeyboardWhenTappedAround()
//        configure(with: currentUser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        profileImageEditButton.layer.cornerRadius = profileImageEditButton.frame.height / 2
    }
    
    // MARK: - setupView
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "프로필 수정"
        
        addSubviews()
        setupConstraints()
        
        emailInfoView.updateInfo("yesle2005")
        familyInfoView.updateInfo("hahaha")
    }
    
    private func addSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(profileImageEditButton)
        view.addSubview(starImageView)
        view.addSubview(starCountLabel)
        view.addSubview(nameStackView)
        view.addSubview(emailInfoView)
        view.addSubview(familyInfoView)
        view.addSubview(profileInfoEditButton)
        
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(nameTextField)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageEditButton.translatesAutoresizingMaskIntoConstraints = false
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starCountLabel.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        emailInfoView.translatesAutoresizingMaskIntoConstraints = false
        familyInfoView.translatesAutoresizingMaskIntoConstraints = false
        profileInfoEditButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 147),
            profileImageView.heightAnchor.constraint(equalToConstant: 158),
            
            profileImageEditButton.widthAnchor.constraint(equalToConstant: 30),
            profileImageEditButton.heightAnchor.constraint(equalToConstant: 30),
            profileImageEditButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5),
            profileImageEditButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -10),
            
            starImageView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 27),
            starImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            starImageView.widthAnchor.constraint(equalToConstant: 19),
            
            starCountLabel.topAnchor.constraint(equalTo: starImageView.topAnchor),
            starCountLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 10),
            
            nameStackView.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 27),
            nameStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailInfoView.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 20),
            emailInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            familyInfoView.topAnchor.constraint(equalTo: emailInfoView.bottomAnchor, constant: 20),
            familyInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            familyInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            profileInfoEditButton.topAnchor.constraint(equalTo: familyInfoView.bottomAnchor, constant: 50),
            profileInfoEditButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileInfoEditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileInfoEditButton.heightAnchor.constraint(equalToConstant: 47),
        ])
    }
    
    // TODO: - 유저 정보 불러오기
//    private func configure(with user: User) {
//        nameTextField.text = user.email.components(separatedBy: "@").first
//        emailInfoView.updateInfo(user.email)
////        familyInfoView.updateInfo(user)
//    }
    
    private func setupButtonActions() {
        profileImageEditButton.addTarget(self, action: #selector(profileImageEditButtonTapped), for: .touchUpInside)
        profileInfoEditButton.addTarget(self, action: #selector(profileInfoEditButtonTapped), for: .touchUpInside)
    }
    
    @objc private func profileImageEditButtonTapped() {
        presentPhotoPicker()
    }
    
    @objc private func profileInfoEditButtonTapped() {
        if profileInfoEditButton.titleLabel?.text == "수정 하기" {
            nameTextField.isUserInteractionEnabled = true
            nameTextField.becomeFirstResponder()
            profileInfoEditButton.setTitle("수정 완료", for: .normal)
        } else {
            view.endEditing(true)
            nameTextField.isUserInteractionEnabled = false
            profileInfoEditButton.setTitle("수정 하기", for: .normal)
            // TODO: - 서버에 이름 저장
        }
    }
    
    private func presentPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        profileImageView.image = selectedImage
        profileImageView.contentMode = .scaleAspectFill
        
        // TODO: - 서버에 프로필 이미지 저장
    }
}

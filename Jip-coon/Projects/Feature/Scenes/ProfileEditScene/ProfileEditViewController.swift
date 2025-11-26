//
//  ProfileEditViewController.swift
//  Feature
//
//  Created by 예슬 on 11/25/25.
//

import UI
import UIKit

final class ProfileEditViewController: UIViewController {
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButtonActions()
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
    }
    
    private func addSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(profileImageEditButton)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageEditButton.translatesAutoresizingMaskIntoConstraints = false
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
            
            
        ])
    }
    
    private func setupButtonActions() {
        profileImageEditButton.addTarget(self, action: #selector(profileImageEditButtonTapped), for: .touchUpInside)
    }
    
    @objc private func profileImageEditButtonTapped() {
        presentPhotoPicker()
    }
    
    private func presentPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
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

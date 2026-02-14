//
//  HomeHeaderView.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import Core
import UIKit

protocol HomeHeaderViewDelegate: AnyObject {
    func didTapCreateFamily()
    func didTapFamilyName()
    func didTapNotification()
}

final class HomeHeaderView: UIView {
    
    weak var delegate: HomeHeaderViewDelegate?
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    
    /// 가족 정보 컨테이너 뷰
    private let familyInfoView = UIView()
    
    /// 가족 생성 버튼 (가족이 없을 때)
    private lazy var createFamilyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ 가족 만들기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(createFamilyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 가족 이름 타이틀 (가족이 있을 때)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(familyNameTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    /// 알림 버튼
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Update
    
    func update(with family: Family?) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        if let family = family {
            setupFamilyView(name: family.name)
        } else {
            setupCreateFamilyView()
        }
    }
    
    private func setupFamilyView(name: String) {
        titleLabel.text = name
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(notificationButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            notificationButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            notificationButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 44),
            notificationButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupCreateFamilyView() {
        containerView.addSubview(createFamilyButton)
        createFamilyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createFamilyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            createFamilyButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func createFamilyButtonTapped() {
        delegate?.didTapCreateFamily()
    }
    
    @objc private func familyNameTapped() {
        delegate?.didTapFamilyName()
    }
    
    @objc private func notificationTapped() {
        delegate?.didTapNotification()
    }
}

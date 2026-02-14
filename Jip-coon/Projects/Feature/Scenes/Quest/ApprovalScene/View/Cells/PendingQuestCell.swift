//
//  PendingQuestCell.swift
//  Feature
//
//  Created by 심관혁 on 12/31/25.
//

import Core
import UI
import UIKit

/// 승인 대기 중인 퀘스트를 표시하는 커스텀 테이블뷰 셀
final class PendingQuestCell: UITableViewCell {
    static let identifier = "PendingQuestCell"
    
    // MARK: - UI Components
    
    // MyTasksTableViewCell과 동일한 컨테이너 스타일 적용
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    // 카테고리 이모지 컨테이너
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    // 제목
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    // 날짜/상태 표시 스택 (MyTasksTableViewCell의 dateStack과 유사)
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let infoIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle", withConfiguration: config))
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // 버튼 스택 뷰 (오른쪽 배치)
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rejectButton, approveButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("승인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 13, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(approveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("거절", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 13, weight: .semibold)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private var quest: Quest?
    var onApprove: ((Quest) -> Void)?
    var onReject: ((Quest) -> Void)?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(infoStack)
        containerView.addSubview(buttonStackView)
        
        infoStack.addArrangedSubview(infoIcon)
        infoStack.addArrangedSubview(infoLabel)
        
        [containerView,
         emojiContainer,
         emojiLabel,
         titleLabel,
         infoStack,
         buttonStackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            emojiContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emojiContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 48),
            emojiContainer.heightAnchor.constraint(equalToConstant: 48),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
            // 버튼 스택뷰를 오른쪽에 배치 (MyTasks의 statusContainer 위치)
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: 110),
            buttonStackView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: buttonStackView.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: emojiContainer.topAnchor, constant: 2),
            
            infoStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: buttonStackView.leadingAnchor, constant: -12)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.containerView.transform = .identity
                }
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        }
    }
    
    // MARK: - Configuration
    
    func configure(with quest: Quest) {
        self.quest = quest
        
        // 이모지 및 배경색
        emojiLabel.text = quest.category.emoji
        let categoryColor = UIColor.questCategoryColor(for: quest.category.backgroundColor)
        emojiContainer.backgroundColor = categoryColor.withAlphaComponent(0.2)
        
        // 제목
        titleLabel.text = quest.title
        
        // 상세 정보 (완료 시간 표시)
        if let completedAt = quest.completedAt {
            infoLabel.text = "완료: " + completedAt.timeAgoString
        } else {
            infoLabel.text = "완료된 퀘스트"
        }
    }
    
    // MARK: - Actions
    
    @objc private func approveButtonTapped() {
        guard let quest = quest else { return }
        onApprove?(quest)
    }
    
    @objc private func rejectButtonTapped() {
        guard let quest = quest else { return }
        onReject?(quest)
    }
}

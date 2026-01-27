//
//  UrgentTaskTableViewCell.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import UIKit
import Core
import UI

/// 긴급 할일 셀
public class UrgentTaskTableViewCell: UITableViewCell {
    public static let identifier = "UrgentTaskTableViewCell"
    
    public var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    // 카드 컨테이너
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        // 그림자
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    // 카테고리 이모지
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    // 카테고리 이모지 라벨
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
    
    // 하단 정보 스택
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    // 날짜 컨테이너
    private lazy var dateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let dateIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let imageView = UIImageView(image: UIImage(systemName: "clock", withConfiguration: config))
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // 긴급도 뱃지
    private let urgencyContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    private let urgencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // 상태 배지
    private let statusContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        
        containerView.addSubview(titleLabel)
        
        containerView.addSubview(infoStack)
        infoStack.addArrangedSubview(dateStack)
        infoStack.addArrangedSubview(urgencyContainer)
        
        dateStack.addArrangedSubview(dateIcon)
        dateStack.addArrangedSubview(dueDateLabel)
        
        urgencyContainer.addSubview(urgencyLabel)
        
        containerView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)
        
        [containerView, emojiContainer, emojiLabel, titleLabel, infoStack, dateStack, urgencyContainer, urgencyLabel, statusContainer, statusLabel].forEach {
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
            
            statusContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusContainer.widthAnchor.constraint(equalToConstant: 72),
            statusContainer.heightAnchor.constraint(equalToConstant: 26),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: emojiContainer.topAnchor, constant: 2),
            
            infoStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: statusContainer.leadingAnchor, constant: -12),
            
            urgencyLabel.leadingAnchor.constraint(equalTo: urgencyContainer.leadingAnchor, constant: 6),
            urgencyLabel.trailingAnchor.constraint(equalTo: urgencyContainer.trailingAnchor, constant: -6),
            urgencyLabel.topAnchor.constraint(equalTo: urgencyContainer.topAnchor, constant: 2),
            urgencyLabel.bottomAnchor.constraint(equalTo: urgencyContainer.bottomAnchor, constant: -2)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        onTap?()
    }
    
    public func configure(
        with quest: Quest,
        urgencyLevel: UrgencyLevel,
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap
        
        // 이모지
        emojiLabel.text = quest.category.emoji
        let categoryColor = UIColor.questCategoryColor(for: quest.category.backgroundColor)
        emojiContainer.backgroundColor = categoryColor.withAlphaComponent(0.2)
        
        // 제목
        titleLabel.text = quest.title
        
        // 날짜
        if let dueDate = quest.dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/dd HH:mm"
            formatter.locale = Locale(identifier: "ko_KR")
            dueDateLabel.text = formatter.string(from: dueDate)
            dateIcon.isHidden = false
            
            // 긴급도에 따라 날짜 색상 변경
            if urgencyLevel == .critical || urgencyLevel == .high {
                dueDateLabel.textColor = .systemRed
                dateIcon.tintColor = .systemRed
            } else {
                dueDateLabel.textColor = .secondaryLabel
                dateIcon.tintColor = .secondaryLabel
            }
        } else {
            dueDateLabel.text = "날짜 미정"
            dateIcon.isHidden = true
        }
        
        // 긴급도 배지
        urgencyLabel.text = "\(urgencyLevel.emoji) \(urgencyLevel.displayName)"
        let urgencyColor = UIColor.questCategoryColor(for: urgencyLevel.color)
        urgencyContainer.backgroundColor = urgencyColor.withAlphaComponent(0.1)
        urgencyLabel.textColor = urgencyColor
        
        // 상태 배지
        statusLabel.text = quest.status.displayName
        let statusColor: UIColor
        switch quest.status {
            case .pending: statusColor = .systemGray
            case .inProgress: statusColor = .mainOrange
            case .completed: statusColor = .systemGreen
            case .approved: statusColor = .systemBlue
            case .rejected: statusColor = .systemRed
        }
        statusContainer.backgroundColor = statusColor.withAlphaComponent(0.1)
        statusLabel.textColor = statusColor
    }
}

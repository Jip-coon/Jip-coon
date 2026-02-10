//
//  AllQuestTableViewCell.swift
//  Feature
//
//  Created by 예슬 on 1/19/26.
//

import Core
import UI
import UIKit

final class AllQuestTableViewCell: UITableViewCell {
    
    static let identifier = "AllQuestTableViewCell"
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
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
    
    private let assigneeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textGray
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray3
        return label
    }()
    
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
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        [emojiContainer, titleLabel, infoStack, statusContainer].forEach {
            containerView.addSubview($0)
        }
        
        emojiContainer.addSubview(emojiLabel)
        statusContainer.addSubview(statusLabel)
        
        dateStack.addArrangedSubview(dateIcon)
        dateStack.addArrangedSubview(dueDateLabel)
        
        infoStack.addArrangedSubview(dateStack)
        infoStack.addArrangedSubview(separatorLabel)
        infoStack.addArrangedSubview(assigneeLabel)
        
        [containerView, emojiContainer, emojiLabel, titleLabel, infoStack, statusContainer, statusLabel].forEach {
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
            infoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: statusContainer.leadingAnchor, constant: -12)
        ])
    }
    
    func configureUI(
        with quest: Quest,
        members: [User],
        segment: AllQuestViewModel.AllQuestSegmentControl
    ) {
        emojiLabel.text = quest.category.emoji
        titleLabel.text = quest.title
        
        let categoryColor = UIColor.questCategoryColor(for: quest.category.backgroundColor)
        emojiContainer.backgroundColor = categoryColor.withAlphaComponent(0.2)
        
        // 담당자 이름 설정
        if let assignedId = quest.assignedTo,
           let member = members.first(where: { $0.id == assignedId }) {
            assigneeLabel.text = member.name
        } else {
            assigneeLabel.text = "미정"
        }
        
        // 마감일 정보
        if let dueDate = quest.dueDate {
            let formatter = DateFormatter()
            if segment == .today {
                formatter.dateFormat = "HH:mm"
            } else {
                formatter.dateFormat = "M/dd HH:mm"
            }
            dueDateLabel.text = formatter.string(from: dueDate)
            dateIcon.isHidden = false
            separatorLabel.isHidden = false
        } else {
            dueDateLabel.text = "날짜 미정"
            dateIcon.isHidden = true
            separatorLabel.isHidden = false
        }
        
        // 상태에 따른 색상 설정
        let statusText = quest.status.displayName
        statusLabel.text = statusText
        
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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        }
    }
}

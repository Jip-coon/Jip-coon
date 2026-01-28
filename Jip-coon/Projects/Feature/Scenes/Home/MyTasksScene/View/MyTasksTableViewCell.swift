//
//  MyTasksTableViewCell.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import UIKit
import Core
import UI

public class MyTasksTableViewCell: UITableViewCell {
    public static let identifier = "MyTasksTableViewCell"
    
    // MARK: - UI Components
    
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
        label.font = .systemFont(ofSize: 17, weight: .bold) // 조금 더 크게, 볼드체
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    // 마감일
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        [emojiContainer, titleLabel, dateStack, statusContainer].forEach {
            containerView.addSubview($0)
        }
        
        emojiContainer.addSubview(emojiLabel)
        statusContainer.addSubview(statusLabel)
        
        dateStack.addArrangedSubview(dateIcon)
        dateStack.addArrangedSubview(dueDateLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateStack.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            dateStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateStack.trailingAnchor.constraint(lessThanOrEqualTo: statusContainer.leadingAnchor, constant: -12)
        ])
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
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
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            if highlighted {
                self.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            } else {
                self.containerView.transform = .identity
            }
        }
    }
    
    public func configure(with quest: Quest, familyMembers: [User]) {
        emojiLabel.text = quest.category.emoji
        titleLabel.text = quest.title
        
        let categoryColor = UIColor.questCategoryColor(for: quest.category.backgroundColor)
        emojiContainer.backgroundColor = categoryColor.withAlphaComponent(0.2)
        
        // 날짜 포맷팅
        if let dueDate = quest.dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "M월 d일 a h:mm" 
            formatter.locale = Locale(identifier: "ko_KR")
            dueDateLabel.text = formatter.string(from: dueDate)
            dateIcon.isHidden = false
        } else {
            dueDateLabel.text = "날짜 미정"
            dateIcon.isHidden = true
        }
        
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
}

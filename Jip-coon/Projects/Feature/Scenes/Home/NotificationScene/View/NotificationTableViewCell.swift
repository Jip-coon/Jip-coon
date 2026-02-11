//
//  NotificationTableViewCell.swift
//  Feature
//
//  Created by 예슬 on 2/11/26.
//

import Core
import UI
import UIKit

final class NotificationTableViewCell: UITableViewCell {
    
    static let identifier: String = NotificationTableViewCell.self.description()
    
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 28
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
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray2
        label.numberOfLines = 1
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  setup
    
    private func setupUI() {
        contentView.addSubview(emojiContainer)
        contentView.addSubview(textStackView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorView)
        
        emojiContainer.addSubview(emojiLabel)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(bodyLabel)
        
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        // Priority
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        bodyLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            emojiContainer.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 18),
            emojiContainer.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emojiContainer.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -19),
            emojiContainer.widthAnchor
                .constraint(equalToConstant: 56),
            emojiContainer.heightAnchor
                .constraint(equalToConstant: 56),
            
            emojiLabel.centerXAnchor
                .constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor
                .constraint(equalTo: emojiContainer.centerYAnchor),
            
            dateLabel.topAnchor
                .constraint(equalTo: emojiContainer.topAnchor),
            dateLabel.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -27),
            
            textStackView.leadingAnchor
                .constraint(equalTo: emojiContainer.trailingAnchor, constant: 19),
            textStackView.trailingAnchor
                .constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -15),
            textStackView.centerYAnchor
                .constraint(equalTo: emojiContainer.centerYAnchor),
            
            separatorView.topAnchor
                .constraint(equalTo: emojiContainer.bottomAnchor, constant: 18),
            separatorView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor
                .constraint(equalToConstant: 1)
        ])
    }
    
    func configureUI(notification: NotificationItem, isToday: Bool) {
        emojiContainer.backgroundColor = UIColor.questCategoryColor(
            for: notification.category?.backgroundColor ?? "yellow1"
        )
        emojiLabel.text = notification.category?.emoji ?? "🍀"
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
        
        if isToday {
            dateLabel.text = notification.createdAt.hhMM
        } else {
            dateLabel.text = notification.createdAt.mmDD
        }
        
        if notification.isRead {
            titleLabel.textColor = .gray
            bodyLabel.textColor = .gray
            contentView.backgroundColor = .gray1
        }
    }
    
}

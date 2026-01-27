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
    
    static let identifier = AllQuestTableViewCell.self.description()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let assigneeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textGray
        return label
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .mainOrange
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
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
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(assigneeLabel)
        containerView.addSubview(dueDateLabel)
        containerView.addSubview(statusLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        assigneeLabel.translatesAutoresizingMaskIntoConstraints = false
        dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor
                .constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            titleLabel.topAnchor
                .constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor
                .constraint(equalTo: statusLabel.leadingAnchor, constant: -20),
            
            assigneeLabel.topAnchor
                .constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            assigneeLabel.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            assigneeLabel.heightAnchor
                .constraint(equalToConstant: 16),
            
            dueDateLabel.centerYAnchor
                .constraint(equalTo: assigneeLabel.centerYAnchor),
            dueDateLabel.leadingAnchor
                .constraint(equalTo: assigneeLabel.trailingAnchor, constant: 12),
            dueDateLabel.trailingAnchor
                .constraint(equalTo: statusLabel.leadingAnchor, constant: -20),
            dueDateLabel.heightAnchor
                .constraint(equalToConstant: 16),
            
            statusLabel.centerYAnchor
                .constraint(equalTo: containerView.centerYAnchor),
            statusLabel.trailingAnchor
                .constraint(equalTo: containerView.trailingAnchor, constant: -20),
            statusLabel.widthAnchor
                .constraint(equalToConstant: 63),
            statusLabel.heightAnchor
                .constraint(equalToConstant: 20),
        ])
    }
    
    func configureUI(with quest: Quest, members: [User]) {
        titleLabel.text = "\(quest.category.emoji) \(quest.title)"
        
        // 담당자 이름 설정
        if let assignedId = quest.assignedTo,
           let member = members.first(where: { $0.id == assignedId }) {
            assigneeLabel.text = "담당자: \(member.name)"
        } else {
            assigneeLabel.text = "담당자: 미정"
        }
        
        // 마감일 정보
        if let dueDate = quest.dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/dd HH:mm"
            dueDateLabel.text = "마감: \(formatter.string(from: dueDate))"
        } else {
            dueDateLabel.text = "마감일 없음"
        }
        
        // 상태에 따른 색상 설정
        let statusColor: UIColor
        switch quest.status {
            case .pending:
                statusColor = .textGray
            case .inProgress:
                statusColor = .mainOrange
            case .completed:
                statusColor = .systemGreen
            case .approved:
                statusColor = .systemBlue
            case .rejected:
                statusColor = .systemRed
        }
        
        let statusText = quest.status.displayName
        statusLabel.text = statusText
        statusLabel.backgroundColor = statusColor
        titleLabel.textColor = statusColor
        
        // 배경색 설정
        containerView.backgroundColor = statusColor.withAlphaComponent(0.1)
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = statusColor
            .withAlphaComponent(0.3).cgColor
    }
    
}

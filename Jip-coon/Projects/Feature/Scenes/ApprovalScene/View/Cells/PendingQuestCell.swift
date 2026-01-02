//
//  PendingQuestCell.swift
//  Feature
//
//  Created by 심관혁 on 12/31/25.
//

import UIKit
import Core
import UI

final class PendingQuestCell: UITableViewCell {
    static let identifier = "PendingQuestCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let categoryIcon: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 24, weight: .regular)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 20
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private let assigneeLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 14, weight: .semibold)
        label.textColor = .mainOrange
        return label
    }()

    private let completedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        return label
    }()

    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("승인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 14, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(approveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("거절", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 14, weight: .semibold)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
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
        containerView.addSubview(categoryIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(assigneeLabel)
        containerView.addSubview(pointsLabel)
        containerView.addSubview(completedDateLabel)
        containerView.addSubview(approveButton)
        containerView.addSubview(rejectButton)

        [containerView, categoryIcon, titleLabel, assigneeLabel, pointsLabel, completedDateLabel, approveButton, rejectButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            categoryIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoryIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            categoryIcon.widthAnchor.constraint(equalToConstant: 40),
            categoryIcon.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: categoryIcon.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            assigneeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            assigneeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            pointsLabel.leadingAnchor.constraint(equalTo: assigneeLabel.trailingAnchor, constant: 8),
            pointsLabel.centerYAnchor.constraint(equalTo: assigneeLabel.centerYAnchor),

            completedDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            completedDateLabel.topAnchor.constraint(equalTo: assigneeLabel.bottomAnchor, constant: 4),
            completedDateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            rejectButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            rejectButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rejectButton.widthAnchor.constraint(equalToConstant: 60),
            rejectButton.heightAnchor.constraint(equalToConstant: 32),

            approveButton.trailingAnchor.constraint(equalTo: rejectButton.leadingAnchor, constant: -8),
            approveButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            approveButton.widthAnchor.constraint(equalToConstant: 60),
            approveButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - Configuration

    func configure(with quest: Quest) {
        self.quest = quest

        titleLabel.text = quest.title
        assigneeLabel.text = "담당자: \(quest.assignedTo ?? "미정")"
        pointsLabel.text = "\(quest.points)P"

        // 카테고리 이모지 및 색상 설정
        categoryIcon.text = quest.category.emoji
        categoryIcon.backgroundColor = UIColor(named: quest.category.backgroundColor, in: uiBundle, compatibleWith: nil)

        // 완료 날짜 표시
        if let completedAt = quest.completedAt {
            completedDateLabel.text = "완료: \(completedAt.timeAgoString)"
        } else {
            completedDateLabel.text = "완료 시간 정보 없음"
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

//
//  UrgentTaskCollectionViewCell.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - 긴급 할 일 컬렉션뷰 셀

public class UrgentTaskCollectionViewCell: UICollectionViewCell {

    static let identifier = "UrgentTaskCollectionViewCell"

    var onTap: (() -> Void)?

    // MARK: - UI 구성요소

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor.textGray
        label.numberOfLines = 1
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()

    // MARK: - 초기화

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 설정

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),

            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            timeLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.contentView.alpha = 0.6
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.contentView.alpha = 1.0
            }
        }

        onTap?()
    }

    // MARK: - 구성

    func configure(with quest: Quest, urgencyLevel: UrgencyLevel, onTap: @escaping () -> Void) {
        self.onTap = onTap
        updateContent(quest: quest, urgencyLevel: urgencyLevel)
        updateAppearance(urgencyLevel: urgencyLevel)
    }

    private func updateContent(quest: Quest, urgencyLevel: UrgencyLevel) {
        titleLabel.text = "\(quest.category.emoji) \(quest.title)"
        timeLabel.text = formatTimeRemaining(for: quest)
        timeLabel.textColor = urgencyLevel.timeColor
    }

    private func updateAppearance(urgencyLevel: UrgencyLevel) {
        contentView.backgroundColor = urgencyLevel.backgroundColor
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = urgencyLevel.borderColor.cgColor
    }

    // MARK: - Helper Methods

    private func formatTimeRemaining(for quest: Quest) -> String {
        guard let dueDate = quest.dueDate else { return "⏰ 시간 미정" }

        let timeRemaining = dueDate.timeIntervalSinceNow

        return timeRemaining < 0
        ? formatOverdueTime(abs(timeRemaining))
        : formatRemainingTime(timeRemaining)
    }

    private func formatOverdueTime(_ overdue: TimeInterval) -> String {
        let hoursOverdue = Int(overdue / 3600)
        return "🚨 \(hoursOverdue)시간 지남"
    }

    private func formatRemainingTime(_ timeRemaining: TimeInterval) -> String {
        let hours = Int(timeRemaining / 3600)
        let minutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)

        return hours > 0
        ? "⏰ \(hours)시간 \(minutes)분 남음"
        : "⏰ \(minutes)분 남음"
    }
}

// MARK: - 빈 상태 셀

public class EmptyUrgentTaskCollectionViewCell: UICollectionViewCell {

    static let identifier = "EmptyUrgentTaskCollectionViewCell"

    // MARK: - UI 구성요소

    private lazy var iconLabel: UILabel = createIconLabel()
    private lazy var messageLabel: UILabel = createMessageLabel()

    // MARK: - 초기화

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 설정

    private func setupUI() {
        configureContentView()
        addSubviews()
        setupConstraints()
    }

    private func configureContentView() {
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
    }

    private func addSubviews() {
        contentView.addSubview(iconLabel)
        contentView.addSubview(messageLabel)
    }

    private func setupConstraints() {
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),

            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 2),
            messageLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - 팩토리 메서드

    private func createIconLabel() -> UILabel {
        let label = UILabel()
        label.text = "✅"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }

    private func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.text = "긴급 할 일이 없어요!"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.systemGreen
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
}

//
//  RecentActivityCollectionViewCell.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - 최근 활동 컬렉션뷰 셀

public class RecentActivityCollectionViewCell: UICollectionViewCell {

    static let identifier = "RecentActivityCollectionViewCell"

    var onTap: (() -> Void)?

    // MARK: - UI 구성요소

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.textGray
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.textGray
        return label
    }()

    private let statusIconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
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
        contentView.layer.cornerRadius = 8

        contentView.addSubview(statusIconLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)

        statusIconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statusIconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusIconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIconLabel.widthAnchor.constraint(equalToConstant: 20),
            statusIconLabel.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: statusIconLabel.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            timeLabel.leadingAnchor.constraint(equalTo: statusIconLabel.trailingAnchor, constant: 8),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        // 탭 애니메이션
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.contentView.transform = .identity
            }
        }

        onTap?()
    }

    // MARK: - 구성

    func configure(with activity: RecentActivity, onTap: @escaping () -> Void) {
        self.onTap = onTap

        titleLabel.text = activity.title
        timeLabel.text = activity.timeText
        statusIconLabel.text = activity.statusIcon

        // 활동 타입에 따른 배경색 설정
        contentView.backgroundColor = activity.backgroundColor
    }
}

// MARK: - 빈 상태 셀

public class EmptyRecentActivityCollectionViewCell: UICollectionViewCell {

    static let identifier = "EmptyRecentActivityCollectionViewCell"

    // MARK: - UI 구성요소

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "📰"
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 활동이 없어요"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.systemGray
        label.textAlignment = .center
        return label
    }()

    private let subMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "가족들과 함께 할 일을 시작해보세요!"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.textGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

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
        contentView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 8

        contentView.addSubview(iconLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(subMessageLabel)

        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        subMessageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),

            subMessageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subMessageLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            subMessageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subMessageLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
        ])
    }
}

// MARK: - 최근 활동 모델

public struct RecentActivity {
    let title: String
    let timeText: String
    let type: ActivityType

    enum ActivityType {
        case completed
        case pending
        case approved
        case rejected
    }

    var statusIcon: String {
        switch type {
        case .completed:
            return "✅"
        case .pending:
            return "⏳"
        case .approved:
            return "👍"
        case .rejected:
            return "❌"
        }
    }

    var backgroundColor: UIColor {
        switch type {
        case .completed:
            return UIColor.systemGreen.withAlphaComponent(0.1)
        case .pending:
            return UIColor.secondaryOrange.withAlphaComponent(0.1)
        case .approved:
            return UIColor.systemBlue.withAlphaComponent(0.1)
        case .rejected:
            return UIColor.systemRed.withAlphaComponent(0.1)
        }
    }

    static func fromString(_ activityString: String, time: String) -> RecentActivity {
        let type: ActivityType

        if activityString.contains("완료") {
            type = .completed
        } else if activityString.contains("승인대기") {
            type = .pending
        } else if activityString.contains("승인") {
            type = .approved
        } else {
            type = .pending
        }

        return RecentActivity(
            title: activityString,
            timeText: time,
            type: type
        )
    }
}

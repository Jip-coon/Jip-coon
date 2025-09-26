//
//  MyTasksCollectionViewCell.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - 내 담당 할일 컬렉션뷰 셀

public class MyTasksCollectionViewCell: UICollectionViewCell {

    static let identifier = "MyTasksCollectionViewCell"

    var onTap: (() -> Void)?

    // MARK: - UI 구성요소

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.textGray
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

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.textGray
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

        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(descriptionLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            statusLabel.widthAnchor.constraint(equalToConstant: 60),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            statusLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
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

    func configure(with quest: Quest, onTap: @escaping () -> Void) {
        self.onTap = onTap

        titleLabel.text = "\(quest.category.emoji) \(quest.title)"
        descriptionLabel.text = quest.description ?? ""

        // 상태에 따른 색상 설정
        let statusColor = quest.status == .inProgress ? UIColor.mainOrange : UIColor.textGray
        let statusText = quest.status.displayName

        statusLabel.text = statusText
        statusLabel.backgroundColor = statusColor

        // 배경색 설정
        contentView.backgroundColor = statusColor.withAlphaComponent(0.1)
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = statusColor.withAlphaComponent(0.3).cgColor
    }
}

// MARK: - 빈 상태 셀

public class EmptyMyTasksCollectionViewCell: UICollectionViewCell {

    static let identifier = "EmptyMyTasksCollectionViewCell"

    // MARK: - UI 구성요소

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉"
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 할 일을 완료했어요!"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        return label
    }()

    private let subMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "새로운 할 일을 추가해보세요"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.textGray
        label.textAlignment = .center
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
        contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor

        contentView.addSubview(iconLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(subMessageLabel)

        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        subMessageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            messageLabel.heightAnchor.constraint(equalToConstant: 20),

            subMessageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subMessageLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            subMessageLabel.heightAnchor.constraint(equalToConstant: 14),
            subMessageLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}

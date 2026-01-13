//
//  CategoryStatsCollectionViewCell.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - 카테고리 통계 컬렉션뷰 셀

public class CategoryStatsCollectionViewCell: UICollectionViewCell {

    static let identifier = "CategoryStatsCollectionViewCell"

    var onTap: (() -> Void)?

    // MARK: - UI 구성요소

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor.textGray
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
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.textGray
            .withAlphaComponent(0.3).cgColor

        contentView.addSubview(emojiLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(nameLabel)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 8),
            emojiLabel.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),

            countLabel.topAnchor
                .constraint(equalTo: emojiLabel.bottomAnchor, constant: 2),
            countLabel.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),
            countLabel.heightAnchor.constraint(equalToConstant: 18),

            nameLabel.topAnchor
                .constraint(equalTo: countLabel.bottomAnchor, constant: 2),
            nameLabel.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 12),
            nameLabel.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
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

    func configure(
        emoji: String,
        name: String,
        count: Int,
        color: UIColor,
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap

        emojiLabel.text = emoji
        countLabel.text = "\(count)"
        countLabel.textColor = color
        nameLabel.text = name
    }
}

// MARK: - 빈 상태 셀

public class EmptyCategoryStatsCollectionViewCell: UICollectionViewCell {

    static let identifier = "EmptyCategoryStatsCollectionViewCell"

    // MARK: - UI 구성요소

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "📊"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "통계 없음"
        label.font = .systemFont(ofSize: 10, weight: .medium)
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
        contentView.backgroundColor = UIColor.systemGray5
            .withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 12

        contentView.addSubview(iconLabel)
        contentView.addSubview(messageLabel)

        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),
            iconLabel.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor, constant: -8),

            messageLabel.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),
            messageLabel.topAnchor
                .constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
        ])
    }
}

// MARK: - 카테고리 정보

public struct CategoryInfo {
    let emoji: String
    let name: String
    let color: UIColor

    static let categoryMapping: [String: CategoryInfo] = [
        "cleaning": CategoryInfo(
            emoji: "🧹",
            name: "청소",
            color: UIColor.systemBlue
        ),
        "cooking": CategoryInfo(
            emoji: "👨‍🍳",
            name: "요리",
            color: UIColor.systemOrange
        ),
        "dishes": CategoryInfo(
            emoji: "🍽️",
            name: "설거지",
            color: UIColor.systemGreen
        ),
        "trash": CategoryInfo(
            emoji: "🗑️",
            name: "쓰레기",
            color: UIColor.systemGray
        ),
        "laundry": CategoryInfo(
            emoji: "👕",
            name: "빨래",
            color: UIColor.systemPurple
        ),
        "pet": CategoryInfo(
            emoji: "🐕",
            name: "반려동물",
            color: UIColor.systemBrown
        ),
        "study": CategoryInfo(
            emoji: "📚",
            name: "공부",
            color: UIColor.systemIndigo
        ),
        "exercise": CategoryInfo(
            emoji: "💪",
            name: "운동",
            color: UIColor.systemRed
        ),
        "other": CategoryInfo(
            emoji: "📝",
            name: "기타",
            color: UIColor.systemTeal
        ),
    ]
}

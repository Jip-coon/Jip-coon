//
//  MainViewComponents.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import Core
import UI
import UIKit

public class MainViewComponents {

    // MARK: - 스크롤뷰와 콘텐츠뷰

    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.backgroundWhite
        return scrollView
    }()

    public let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundWhite
        return view
    }()

    // MARK: - 헤더 컴포넌트들

    public let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.headerBeige
        view.layer.cornerRadius = 0
        return view
    }()

    public let userProfileView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    public let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.headerText.withAlphaComponent(0.3)
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    public let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름 (부모)"  // 더미 데이터
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.headerText
        return label
    }()

    public let pointsLabel: UILabel = {
        let label = UILabel()
        label.text = "⭐ 250 포인트"  // 더미 데이터
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.headerText
        return label
    }()

    public let familyInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    public let familyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "🏠 우리가족"  // 더미 데이터
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.headerText
        return label
    }()

    public let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔔 2", for: .normal)  // 더미 데이터
        button.setTitleColor(UIColor.headerText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.backgroundColor = UIColor.headerNotiBack.withAlphaComponent(0.8)
        button.layer.cornerRadius = 12
        return button
    }()

    // MARK: - 섹션 컴포넌트들

    // 긴급 할일 섹션
    public let urgentSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    public let urgentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🚨 긴급 할일"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.textRed
        return label
    }()

    public let urgentTaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.textRed.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.textRed.withAlphaComponent(0.3).cgColor
        return view
    }()

    public let urgentTaskTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🗑️ 쓰레기 배출"  // 더미 데이터
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.textGray
        return label
    }()

    public let urgentTaskTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "⏰ 2시간 남음"  // 더미 데이터
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.textGray
        return label
    }()

    // 내 담당 할일 섹션
    public let myTasksSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    public let myTasksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📌 내가 담당한 할일"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public let myTasksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()

    // 통계 섹션
    public let statsSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    public let statsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📊 이번 주 현황"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.mainOrange
        progressView.trackTintColor = UIColor.mainOrange.withAlphaComponent(0.2)
        progressView.progress = 0.75
        return progressView
    }()

    public let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "75%"  // 더미 데이터
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public let categoryStatsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()

    // 빠른 액션 섹션
    public let quickActionsSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    public let quickActionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "⚡ 빠른 실행"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public let quickActionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    // 최근 활동 섹션
    public let recentActivitySectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    public let recentActivityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📰 가족 활동"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public let recentActivityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()

    // 성취 섹션
    public let achievementSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    public let achievementTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🏆 성취"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public let achievementLabel: UILabel = {
        let label = UILabel()
        label.text = "🔥 5일 연속 달성!\n👑 이번 주 청소 마스터\n⭐ 120pt 획득"  // 더미 데이터
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.textGray
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Functions

    public func createTaskView(
        title: String, status: String, statusColor: UIColor, description: String
    ) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = statusColor.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = statusColor.withAlphaComponent(0.3).cgColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.textGray

        let statusLabel = UILabel()
        statusLabel.text = status
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = .white
        statusLabel.backgroundColor = statusColor
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true

        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor.textGray

        containerView.addSubview(titleLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(descriptionLabel)

        // Auto Layout 설정
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(equalToConstant: 60),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
        ])

        return containerView
    }

    public func createActivityView(title: String, time: String, backgroundColor: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.textGray
        titleLabel.numberOfLines = 0

        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = UIColor.textGray

        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)

        // Auto Layout 설정
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ])

        return containerView
    }

    public func setupQuickActionButtons() -> [UIButton] {
        let buttonTitles = ["➕\n새 퀘스트", "🔍\n검색", "👥\n초대", "✅\n승인"]
        var buttons: [UIButton] = []

        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.mainOrange, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = UIColor.mainOrange.withAlphaComponent(0.1)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mainOrange.withAlphaComponent(0.3).cgColor

            quickActionsStackView.addArrangedSubview(button)
            buttons.append(button)
        }

        return buttons
    }

    public func setupCategoryStatsIcons(with stats: [String: Int]) {
        // 기존 아이콘들 제거
        categoryStatsStackView.arrangedSubviews.forEach { view in
            categoryStatsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let categoryInfo: [String: (emoji: String, name: String, color: UIColor)] = [
            "cleaning": ("🧹", "청소", UIColor.systemBlue),
            "cooking": ("👨‍🍳", "요리", UIColor.systemOrange),
            "dishes": ("🍽️", "설거지", UIColor.systemGreen),
            "trash": ("🗑️", "쓰레기", UIColor.systemGray),
            "laundry": ("👕", "빨래", UIColor.systemPurple),
            "pet": ("🐕", "반려동물", UIColor.systemBrown),
            "study": ("📚", "공부", UIColor.systemIndigo),
            "exercise": ("💪", "운동", UIColor.systemRed),
            "other": ("📝", "기타", UIColor.systemTeal),
        ]

        // 통계가 있는 카테고리만 표시 (최대 4개)
        let sortedStats = stats.sorted { $0.value > $1.value }.prefix(4)

        for (key, count) in sortedStats {
            guard let info = categoryInfo[key], count > 0 else { continue }

            let iconView = createCategoryIconView(
                emoji: info.emoji,
                name: info.name,
                count: count,
                color: info.color
            )

            categoryStatsStackView.addArrangedSubview(iconView)
        }

        // 빈 공간 채우기 (4개 미만일 때)
        while categoryStatsStackView.arrangedSubviews.count < 4 {
            let spacerView = UIView()
            spacerView.backgroundColor = .clear
            categoryStatsStackView.addArrangedSubview(spacerView)
        }
    }

    private func createCategoryIconView(emoji: String, name: String, count: Int, color: UIColor)
    -> UIView
    {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 20)
        emojiLabel.textAlignment = .center

        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .systemFont(ofSize: 16, weight: .bold)
        countLabel.textColor = color
        countLabel.textAlignment = .center

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 10, weight: .medium)
        nameLabel.textColor = UIColor.textGray
        nameLabel.textAlignment = .center

        containerView.addSubview(emojiLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(nameLabel)

        // Auto Layout 설정
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            countLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 2),
            countLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 2),
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            containerView.heightAnchor.constraint(equalToConstant: 70),
        ])

        return containerView
    }
}

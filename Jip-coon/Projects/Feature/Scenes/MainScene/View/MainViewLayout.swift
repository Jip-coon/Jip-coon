//
//  MainViewLayout.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import UI
import UIKit

public class MainViewLayout {

    private let components: MainViewComponents

    public init(components: MainViewComponents) {
        self.components = components
    }

    public func setupViewHierarchy(in view: UIView) {
        view.addSubview(components.scrollView)
        components.scrollView.addSubview(components.contentView)
        view.addSubview(components.headerView)
        setupHeaderHierarchy()
        setupContentHierarchy()
    }

    private func setupHeaderHierarchy() {
        components.headerView.addSubview(components.userProfileView)
        components.headerView.addSubview(components.familyInfoView)

        // 사용자 프로필 뷰
        components.userProfileView.addSubview(components.profileImageView)
        components.userProfileView.addSubview(components.userNameLabel)
        components.userProfileView.addSubview(components.pointsLabel)

        // 가족 정보 뷰
        components.familyInfoView.addSubview(components.familyNameLabel)
        components.familyInfoView.addSubview(components.notificationButton)
    }

    private func setupContentHierarchy() {
        // 긴급 할일 섹션
        components.contentView.addSubview(components.urgentSectionView)
        components.urgentSectionView.addSubview(components.urgentTitleLabel)
        components.urgentSectionView.addSubview(components.urgentTaskView)
        components.urgentTaskView.addSubview(components.urgentTaskTitleLabel)
        components.urgentTaskView.addSubview(components.urgentTaskTimeLabel)

        // 내 담당 할일 섹션
        components.contentView.addSubview(components.myTasksSectionView)
        components.myTasksSectionView.addSubview(components.myTasksTitleLabel)
        components.myTasksSectionView.addSubview(components.myTasksStackView)

        // 통계 섹션
        components.contentView.addSubview(components.statsSectionView)
        components.statsSectionView.addSubview(components.statsTitleLabel)
        components.statsSectionView.addSubview(components.progressView)
        components.statsSectionView.addSubview(components.progressLabel)
        components.statsSectionView.addSubview(components.categoryStatsStackView)

        // 빠른 액션 섹션
        components.contentView.addSubview(components.quickActionsSectionView)
        components.quickActionsSectionView.addSubview(components.quickActionsTitleLabel)
        components.quickActionsSectionView.addSubview(components.quickActionsStackView)

        // 최근 활동 섹션
        components.contentView.addSubview(components.recentActivitySectionView)
        components.recentActivitySectionView.addSubview(components.recentActivityTitleLabel)
        components.recentActivitySectionView.addSubview(components.recentActivityStackView)

        // 성취 섹션
        components.contentView.addSubview(components.achievementSectionView)
        components.achievementSectionView.addSubview(components.achievementTitleLabel)
        components.achievementSectionView.addSubview(components.achievementLabel)
    }

    public func setupConstraints(in view: UIView) {
        // 모든 뷰에 대해 translatesAutoresizingMaskIntoConstraints = false 설정
        setTranslatesAutoresizingMaskIntoConstraintsFalse()

        NSLayoutConstraint.activate([
            // 헤더 제약조건
            components.headerView.topAnchor.constraint(equalTo: view.topAnchor),
            components.headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            components.headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            components.headerView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            // 사용자 프로필 뷰
            components.userProfileView.leadingAnchor.constraint(
                equalTo: components.headerView.leadingAnchor, constant: 20),
            components.userProfileView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            components.profileImageView.leadingAnchor.constraint(
                equalTo: components.userProfileView.leadingAnchor),
            components.profileImageView.topAnchor.constraint(
                equalTo: components.userProfileView.topAnchor),
            components.profileImageView.widthAnchor.constraint(equalToConstant: 50),
            components.profileImageView.heightAnchor.constraint(equalToConstant: 50),

            components.userNameLabel.leadingAnchor.constraint(
                equalTo: components.profileImageView.trailingAnchor, constant: 12),
            components.userNameLabel.topAnchor.constraint(equalTo: components.userProfileView.topAnchor),
            components.userNameLabel.trailingAnchor.constraint(
                equalTo: components.userProfileView.trailingAnchor),

            components.pointsLabel.leadingAnchor.constraint(
                equalTo: components.profileImageView.trailingAnchor, constant: 12),
            components.pointsLabel.topAnchor.constraint(
                equalTo: components.userNameLabel.bottomAnchor, constant: 4),
            components.pointsLabel.trailingAnchor.constraint(
                equalTo: components.userProfileView.trailingAnchor),
            components.pointsLabel.bottomAnchor.constraint(
                equalTo: components.userProfileView.bottomAnchor),

            // 가족 정보 뷰
            components.familyInfoView.trailingAnchor.constraint(
                equalTo: components.headerView.trailingAnchor, constant: -20),
            components.familyInfoView.centerYAnchor.constraint(
                equalTo: components.userProfileView.centerYAnchor),

            components.familyNameLabel.topAnchor.constraint(equalTo: components.familyInfoView.topAnchor),
            components.familyNameLabel.trailingAnchor.constraint(
                equalTo: components.familyInfoView.trailingAnchor),

            components.notificationButton.topAnchor.constraint(
                equalTo: components.familyNameLabel.bottomAnchor, constant: 8),
            components.notificationButton.trailingAnchor.constraint(
                equalTo: components.familyInfoView.trailingAnchor),
            components.notificationButton.bottomAnchor.constraint(
                equalTo: components.familyInfoView.bottomAnchor),
            components.notificationButton.widthAnchor.constraint(equalToConstant: 50),
            components.notificationButton.heightAnchor.constraint(equalToConstant: 24),

            // 스크롤뷰 제약조건
            components.scrollView.topAnchor.constraint(equalTo: components.headerView.bottomAnchor),
            components.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            components.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            components.scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // 콘텐츠뷰 제약조건
            components.contentView.topAnchor.constraint(equalTo: components.scrollView.topAnchor),
            components.contentView.leadingAnchor.constraint(equalTo: components.scrollView.leadingAnchor),
            components.contentView.trailingAnchor.constraint(
                equalTo: components.scrollView.trailingAnchor),
            components.contentView.bottomAnchor.constraint(equalTo: components.scrollView.bottomAnchor),
            components.contentView.widthAnchor.constraint(equalTo: components.scrollView.widthAnchor),
        ])

        setupSectionConstraints()
    }

    private func setupSectionConstraints() {
        NSLayoutConstraint.activate([
            // 긴급 할일 섹션
            components.urgentSectionView.topAnchor.constraint(
                equalTo: components.contentView.topAnchor, constant: 20),
            components.urgentSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.urgentSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),

            components.urgentTitleLabel.topAnchor.constraint(
                equalTo: components.urgentSectionView.topAnchor, constant: 16),
            components.urgentTitleLabel.leadingAnchor.constraint(
                equalTo: components.urgentSectionView.leadingAnchor, constant: 16),
            components.urgentTitleLabel.trailingAnchor.constraint(
                equalTo: components.urgentSectionView.trailingAnchor, constant: -16),

            components.urgentTaskView.topAnchor.constraint(
                equalTo: components.urgentTitleLabel.bottomAnchor, constant: 12),
            components.urgentTaskView.leadingAnchor.constraint(
                equalTo: components.urgentSectionView.leadingAnchor, constant: 16),
            components.urgentTaskView.trailingAnchor.constraint(
                equalTo: components.urgentSectionView.trailingAnchor, constant: -16),
            components.urgentTaskView.bottomAnchor.constraint(
                equalTo: components.urgentSectionView.bottomAnchor, constant: -16),

            components.urgentTaskTitleLabel.topAnchor.constraint(
                equalTo: components.urgentTaskView.topAnchor, constant: 12),
            components.urgentTaskTitleLabel.leadingAnchor.constraint(
                equalTo: components.urgentTaskView.leadingAnchor, constant: 16),

            components.urgentTaskTimeLabel.centerYAnchor.constraint(
                equalTo: components.urgentTaskTitleLabel.centerYAnchor),
            components.urgentTaskTimeLabel.trailingAnchor.constraint(
                equalTo: components.urgentTaskView.trailingAnchor, constant: -16),
            components.urgentTaskTimeLabel.bottomAnchor.constraint(
                equalTo: components.urgentTaskView.bottomAnchor, constant: -12),

            // 내 담당 할일 섹션
            components.myTasksSectionView.topAnchor.constraint(
                equalTo: components.urgentSectionView.bottomAnchor, constant: 20),
            components.myTasksSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.myTasksSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),

            components.myTasksTitleLabel.topAnchor.constraint(
                equalTo: components.myTasksSectionView.topAnchor, constant: 16),
            components.myTasksTitleLabel.leadingAnchor.constraint(
                equalTo: components.myTasksSectionView.leadingAnchor, constant: 16),
            components.myTasksTitleLabel.trailingAnchor.constraint(
                equalTo: components.myTasksSectionView.trailingAnchor, constant: -16),

            components.myTasksStackView.topAnchor.constraint(
                equalTo: components.myTasksTitleLabel.bottomAnchor, constant: 12),
            components.myTasksStackView.leadingAnchor.constraint(
                equalTo: components.myTasksSectionView.leadingAnchor, constant: 16),
            components.myTasksStackView.trailingAnchor.constraint(
                equalTo: components.myTasksSectionView.trailingAnchor, constant: -16),
            components.myTasksStackView.bottomAnchor.constraint(
                equalTo: components.myTasksSectionView.bottomAnchor, constant: -16),

            // 통계 섹션
            components.statsSectionView.topAnchor.constraint(
                equalTo: components.myTasksSectionView.bottomAnchor, constant: 20),
            components.statsSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.statsSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),

            components.statsTitleLabel.topAnchor.constraint(
                equalTo: components.statsSectionView.topAnchor, constant: 16),
            components.statsTitleLabel.leadingAnchor.constraint(
                equalTo: components.statsSectionView.leadingAnchor, constant: 16),
            components.statsTitleLabel.trailingAnchor.constraint(
                equalTo: components.statsSectionView.trailingAnchor, constant: -16),

            components.progressView.topAnchor.constraint(
                equalTo: components.statsTitleLabel.bottomAnchor, constant: 12),
            components.progressView.leadingAnchor.constraint(
                equalTo: components.statsSectionView.leadingAnchor, constant: 16),
            components.progressView.trailingAnchor.constraint(
                equalTo: components.progressLabel.leadingAnchor, constant: -12),
            components.progressView.heightAnchor.constraint(equalToConstant: 8),

            components.progressLabel.centerYAnchor.constraint(
                equalTo: components.progressView.centerYAnchor),
            components.progressLabel.trailingAnchor.constraint(
                equalTo: components.statsSectionView.trailingAnchor, constant: -16),
            components.progressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),

            components.categoryStatsStackView.topAnchor.constraint(
                equalTo: components.progressView.bottomAnchor, constant: 16),
            components.categoryStatsStackView.leadingAnchor.constraint(
                equalTo: components.statsSectionView.leadingAnchor, constant: 16),
            components.categoryStatsStackView.trailingAnchor.constraint(
                equalTo: components.statsSectionView.trailingAnchor, constant: -16),
            components.categoryStatsStackView.bottomAnchor.constraint(
                equalTo: components.statsSectionView.bottomAnchor, constant: -16),
            components.categoryStatsStackView.heightAnchor.constraint(equalToConstant: 70),

            // 빠른 액션 섹션
            components.quickActionsSectionView.topAnchor.constraint(
                equalTo: components.statsSectionView.bottomAnchor, constant: 20),
            components.quickActionsSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.quickActionsSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),

            components.quickActionsTitleLabel.topAnchor.constraint(
                equalTo: components.quickActionsSectionView.topAnchor, constant: 16),
            components.quickActionsTitleLabel.leadingAnchor.constraint(
                equalTo: components.quickActionsSectionView.leadingAnchor, constant: 16),
            components.quickActionsTitleLabel.trailingAnchor.constraint(
                equalTo: components.quickActionsSectionView.trailingAnchor, constant: -16),

            components.quickActionsStackView.topAnchor.constraint(
                equalTo: components.quickActionsTitleLabel.bottomAnchor, constant: 12),
            components.quickActionsStackView.leadingAnchor.constraint(
                equalTo: components.quickActionsSectionView.leadingAnchor, constant: 16),
            components.quickActionsStackView.trailingAnchor.constraint(
                equalTo: components.quickActionsSectionView.trailingAnchor, constant: -16),
            components.quickActionsStackView.bottomAnchor.constraint(
                equalTo: components.quickActionsSectionView.bottomAnchor, constant: -16),
            components.quickActionsStackView.heightAnchor.constraint(equalToConstant: 60),

            // 최근 활동 섹션
            components.recentActivitySectionView.topAnchor.constraint(
                equalTo: components.quickActionsSectionView.bottomAnchor, constant: 20),
            components.recentActivitySectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.recentActivitySectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),

            components.recentActivityTitleLabel.topAnchor.constraint(
                equalTo: components.recentActivitySectionView.topAnchor, constant: 16),
            components.recentActivityTitleLabel.leadingAnchor.constraint(
                equalTo: components.recentActivitySectionView.leadingAnchor, constant: 16),
            components.recentActivityTitleLabel.trailingAnchor.constraint(
                equalTo: components.recentActivitySectionView.trailingAnchor, constant: -16),

            components.recentActivityStackView.topAnchor.constraint(
                equalTo: components.recentActivityTitleLabel.bottomAnchor, constant: 12),
            components.recentActivityStackView.leadingAnchor.constraint(
                equalTo: components.recentActivitySectionView.leadingAnchor, constant: 16),
            components.recentActivityStackView.trailingAnchor.constraint(
                equalTo: components.recentActivitySectionView.trailingAnchor, constant: -16),
            components.recentActivityStackView.bottomAnchor.constraint(
                equalTo: components.recentActivitySectionView.bottomAnchor, constant: -16),

            // 성취 섹션
            components.achievementSectionView.topAnchor.constraint(
                equalTo: components.recentActivitySectionView.bottomAnchor, constant: 20),
            components.achievementSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.achievementSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),
            components.achievementSectionView.bottomAnchor.constraint(
                equalTo: components.contentView.bottomAnchor, constant: -20),

            components.achievementTitleLabel.topAnchor.constraint(
                equalTo: components.achievementSectionView.topAnchor, constant: 16),
            components.achievementTitleLabel.leadingAnchor.constraint(
                equalTo: components.achievementSectionView.leadingAnchor, constant: 16),
            components.achievementTitleLabel.trailingAnchor.constraint(
                equalTo: components.achievementSectionView.trailingAnchor, constant: -16),

            components.achievementLabel.topAnchor.constraint(
                equalTo: components.achievementTitleLabel.bottomAnchor, constant: 12),
            components.achievementLabel.leadingAnchor.constraint(
                equalTo: components.achievementSectionView.leadingAnchor, constant: 16),
            components.achievementLabel.trailingAnchor.constraint(
                equalTo: components.achievementSectionView.trailingAnchor, constant: -16),
            components.achievementLabel.bottomAnchor.constraint(
                equalTo: components.achievementSectionView.bottomAnchor, constant: -16),
        ])
    }

    private func setTranslatesAutoresizingMaskIntoConstraintsFalse() {
        components.scrollView.translatesAutoresizingMaskIntoConstraints = false
        components.contentView.translatesAutoresizingMaskIntoConstraints = false
        components.headerView.translatesAutoresizingMaskIntoConstraints = false
        components.userProfileView.translatesAutoresizingMaskIntoConstraints = false
        components.familyInfoView.translatesAutoresizingMaskIntoConstraints = false
        components.profileImageView.translatesAutoresizingMaskIntoConstraints = false
        components.userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        components.pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        components.familyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        components.notificationButton.translatesAutoresizingMaskIntoConstraints = false

        // 섹션 뷰들
        components.urgentSectionView.translatesAutoresizingMaskIntoConstraints = false
        components.urgentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.urgentTaskView.translatesAutoresizingMaskIntoConstraints = false
        components.urgentTaskTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.urgentTaskTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        components.myTasksSectionView.translatesAutoresizingMaskIntoConstraints = false
        components.myTasksTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.myTasksStackView.translatesAutoresizingMaskIntoConstraints = false

        components.statsSectionView.translatesAutoresizingMaskIntoConstraints = false
        components.statsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.progressView.translatesAutoresizingMaskIntoConstraints = false
        components.progressLabel.translatesAutoresizingMaskIntoConstraints = false
        components.categoryStatsStackView.translatesAutoresizingMaskIntoConstraints = false

        components.quickActionsSectionView.translatesAutoresizingMaskIntoConstraints = false
        components.quickActionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.quickActionsStackView.translatesAutoresizingMaskIntoConstraints = false

        components.recentActivitySectionView.translatesAutoresizingMaskIntoConstraints = false
        components.recentActivityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.recentActivityStackView.translatesAutoresizingMaskIntoConstraints = false

        components.achievementSectionView.translatesAutoresizingMaskIntoConstraints = false
        components.achievementTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        components.achievementLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}

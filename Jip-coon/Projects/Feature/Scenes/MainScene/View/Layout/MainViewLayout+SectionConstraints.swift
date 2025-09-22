//
//  MainViewLayout+SectionConstraints.swift
//  Feature
//
//  Created by 심관혁 on 9/18/25.
//

import UI
import UIKit

// MARK: - Section Constraints Setup

extension MainViewLayout {

    internal func setupSectionConstraints() {
        NSLayoutConstraint.activate([
            // 긴급 할일 섹션
            components.urgentSectionView.topAnchor.constraint(
                equalTo: components.contentView.topAnchor, constant: 20),
            components.urgentSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.urgentSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),
            components.urgentSectionView.heightAnchor.constraint(equalToConstant: 150),

            // 긴급 할일 타이틀과 개수
            components.urgentTitleLabel.topAnchor.constraint(
                equalTo: components.urgentSectionView.topAnchor, constant: 16),
            components.urgentTitleLabel.leadingAnchor.constraint(
                equalTo: components.urgentSectionView.leadingAnchor, constant: 16),

            components.urgentCountLabel.centerYAnchor.constraint(
                equalTo: components.urgentTitleLabel.centerYAnchor),
            components.urgentCountLabel.trailingAnchor.constraint(
                equalTo: components.urgentSectionView.trailingAnchor, constant: -16),
            components.urgentCountLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: components.urgentTitleLabel.trailingAnchor, constant: 8),

            // 긴급 할일 컬렉션뷰
            components.urgentCollectionView.topAnchor.constraint(
                equalTo: components.urgentTitleLabel.bottomAnchor, constant: 12),
            components.urgentCollectionView.leadingAnchor.constraint(
                equalTo: components.urgentSectionView.leadingAnchor, constant: 16),
            components.urgentCollectionView.trailingAnchor.constraint(
                equalTo: components.urgentSectionView.trailingAnchor, constant: -16),
            components.urgentCollectionView.heightAnchor.constraint(equalToConstant: 60),

            // 긴급 할일 페이지 인디케이터
            components.urgentPageControl.topAnchor.constraint(
                equalTo: components.urgentCollectionView.bottomAnchor, constant: 8),
            components.urgentPageControl.centerXAnchor.constraint(
                equalTo: components.urgentSectionView.centerXAnchor),
            components.urgentPageControl.heightAnchor.constraint(equalToConstant: 20),
            components.urgentPageControl.bottomAnchor.constraint(
                equalTo: components.urgentSectionView.bottomAnchor, constant: -12),

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

            components.myTasksCollectionView.topAnchor.constraint(
                equalTo: components.myTasksTitleLabel.bottomAnchor, constant: 12),
            components.myTasksCollectionView.leadingAnchor.constraint(
                equalTo: components.myTasksSectionView.leadingAnchor, constant: 16),
            components.myTasksCollectionView.trailingAnchor.constraint(
                equalTo: components.myTasksSectionView.trailingAnchor, constant: -16),
            components.myTasksCollectionView.bottomAnchor.constraint(
                equalTo: components.myTasksSectionView.bottomAnchor, constant: -16),

            // 통계 섹션
            components.statsSectionView.topAnchor.constraint(
                equalTo: components.myTasksSectionView.bottomAnchor, constant: 20),
            components.statsSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.statsSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),
            components.statsSectionView.heightAnchor.constraint(equalToConstant: 172),

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
            components.progressView.heightAnchor.constraint(equalToConstant: 8),
            components.progressView.trailingAnchor.constraint(
                equalTo: components.progressLabel.leadingAnchor, constant: -12),

            components.progressLabel.centerYAnchor.constraint(
                equalTo: components.progressView.centerYAnchor),
            components.progressLabel.trailingAnchor.constraint(
                equalTo: components.statsSectionView.trailingAnchor, constant: -16),
            components.progressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),

            components.categoryStatsCollectionView.topAnchor.constraint(
                equalTo: components.progressView.bottomAnchor, constant: 16),
            components.categoryStatsCollectionView.leadingAnchor.constraint(
                equalTo: components.statsSectionView.leadingAnchor, constant: 16),
            components.categoryStatsCollectionView.trailingAnchor.constraint(
                equalTo: components.statsSectionView.trailingAnchor, constant: -16),
            components.categoryStatsCollectionView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 80),
            components.categoryStatsCollectionView.bottomAnchor.constraint(
                equalTo: components.statsSectionView.bottomAnchor, constant: -16),

            // 빠른 액션 섹션
            components.quickActionsSectionView.topAnchor.constraint(
                equalTo: components.statsSectionView.bottomAnchor, constant: 20),
            components.quickActionsSectionView.leadingAnchor.constraint(
                equalTo: components.contentView.leadingAnchor, constant: 20),
            components.quickActionsSectionView.trailingAnchor.constraint(
                equalTo: components.contentView.trailingAnchor, constant: -20),
            components.quickActionsSectionView.heightAnchor.constraint(equalToConstant: 126),

            components.quickActionsTitleLabel.topAnchor.constraint(
                equalTo: components.quickActionsSectionView.topAnchor, constant: 16),
            components.quickActionsTitleLabel.leadingAnchor.constraint(
                equalTo: components.quickActionsSectionView.leadingAnchor, constant: 16),
            components.quickActionsTitleLabel.trailingAnchor.constraint(
                equalTo: components.quickActionsSectionView.trailingAnchor, constant: -16),

            components.quickActionsCollectionView.topAnchor.constraint(
                equalTo: components.quickActionsTitleLabel.bottomAnchor, constant: 12),
            components.quickActionsCollectionView.leadingAnchor.constraint(
                equalTo: components.quickActionsSectionView.leadingAnchor, constant: 16),
            components.quickActionsCollectionView.trailingAnchor.constraint(
                equalTo: components.quickActionsSectionView.trailingAnchor, constant: -16),
            components.quickActionsCollectionView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 60),
            components.quickActionsCollectionView.bottomAnchor.constraint(
                equalTo: components.quickActionsSectionView.bottomAnchor, constant: -16),

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

            components.recentActivityCollectionView.topAnchor.constraint(
                equalTo: components.recentActivityTitleLabel.bottomAnchor, constant: 12),
            components.recentActivityCollectionView.leadingAnchor.constraint(
                equalTo: components.recentActivitySectionView.leadingAnchor, constant: 16),
            components.recentActivityCollectionView.trailingAnchor.constraint(
                equalTo: components.recentActivitySectionView.trailingAnchor, constant: -16),
            components.recentActivityCollectionView.bottomAnchor.constraint(
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

        components.myTasksCollectionViewHeightConstraint = components.myTasksCollectionView.heightAnchor
            .constraint(equalToConstant: 80)  // 최소 높이로 초기화
        components.myTasksCollectionViewHeightConstraint?.isActive = true

        components.recentActivityCollectionViewHeightConstraint = components
            .recentActivityCollectionView.heightAnchor
            .constraint(equalToConstant: 68)  // 최소 높이로 초기화
        components.recentActivityCollectionViewHeightConstraint?.isActive = true
    }
}

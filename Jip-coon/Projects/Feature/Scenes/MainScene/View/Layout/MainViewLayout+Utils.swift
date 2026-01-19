//
//  MainViewLayout+Utils.swift
//  Feature
//
//  Created by 심관혁 on 9/18/25.
//

import UI
import UIKit

// MARK: - Utility Methods

extension MainViewLayout {

    internal func setTranslatesAutoresizingMaskIntoConstraintsFalse() {
        // 기본 레이아웃 뷰들
        UIView.disableAutoresizingMask(for: [
            components.scrollView,
            components.contentView,
            components.headerView,
            components.userProfileView,
            components.familyInfoView,
            components.profileImageView,
            components.userNameLabel,
            components.pointsLabel,
            components.familyNameButton,
            components.notificationButton,
            components.createFamilyButton,
        ])

        // 긴급 할일 섹션
        UIView.disableAutoresizingMask(for: [
            components.urgentSectionView,
            components.urgentTitleLabel,
            components.urgentCountLabel,
            components.urgentCollectionView,
            components.urgentPageControl,
        ])

        // 내 담당 할일 섹션
        UIView.disableAutoresizingMask(for: [
            components.myTasksSectionView,
            components.myTasksTitleLabel,
            components.myTasksCollectionView,
        ])

        // 통계 섹션
        UIView.disableAutoresizingMask(for: [
            components.statsSectionView,
            components.statsTitleLabel,
            components.progressView,
            components.progressLabel,
            components.categoryStatsCollectionView,
        ])

        // 빠른 액션 섹션
        UIView.disableAutoresizingMask(for: [
            components.quickActionsSectionView,
            components.quickActionsTitleLabel,
            components.quickActionsCollectionView,
        ])

        // 최근 활동 섹션
        UIView.disableAutoresizingMask(for: [
            components.recentActivitySectionView,
            components.recentActivityTitleLabel,
            components.recentActivityCollectionView,
        ])

        // 성취 섹션
        UIView.disableAutoresizingMask(for: [
            components.achievementSectionView,
            components.achievementTitleLabel,
            components.achievementLabel,
        ])
    }
}

//
//  MainViewLayout+Hierarchy.swift
//  Feature
//
//  Created by 심관혁 on 9/18/25.
//

import UI
import UIKit

// MARK: - View Hierarchy Setup

extension MainViewLayout {

    internal func setupHeaderHierarchy() {
        components.headerView.addSubview(components.userProfileView)
        components.headerView.addSubview(components.familyInfoView)

        // 사용자 프로필 뷰
        components.userProfileView.addSubview(components.profileImageView)
        components.userProfileView.addSubview(components.userNameLabel)
        components.userProfileView.addSubview(components.pointsLabel)

        // 가족 정보 뷰는 동적으로 추가됨 (MainViewController에서)
    }

    internal func setupContentHierarchy() {
        // 긴급 할일 섹션
        components.contentView.addSubview(components.urgentSectionView)
        components.urgentSectionView.addSubview(components.urgentTitleLabel)
        components.urgentSectionView.addSubview(components.urgentCountLabel)
        components.urgentSectionView.addSubview(components.urgentCollectionView)
        components.urgentSectionView.addSubview(components.urgentPageControl)

        // 내 담당 할일 섹션
        components.contentView.addSubview(components.myTasksSectionView)
        components.myTasksSectionView.addSubview(components.myTasksTitleLabel)
        components.myTasksSectionView
            .addSubview(components.myTasksCollectionView)

        // 통계 섹션
        components.contentView.addSubview(components.statsSectionView)
        components.statsSectionView.addSubview(components.statsTitleLabel)
        components.statsSectionView.addSubview(components.progressView)
        components.statsSectionView.addSubview(components.progressLabel)
        components.statsSectionView
            .addSubview(components.categoryStatsCollectionView)

        // 빠른 액션 섹션
        components.contentView.addSubview(components.quickActionsSectionView)
        components.quickActionsSectionView
            .addSubview(components.quickActionsTitleLabel)
        components.quickActionsSectionView
            .addSubview(components.quickActionsCollectionView)

        // 최근 활동 섹션
        components.contentView.addSubview(components.recentActivitySectionView)
        components.recentActivitySectionView
            .addSubview(components.recentActivityTitleLabel)
        components.recentActivitySectionView
            .addSubview(components.recentActivityCollectionView)

        // 성취 섹션
        components.contentView.addSubview(components.achievementSectionView)
        components.achievementSectionView
            .addSubview(components.achievementTitleLabel)
        components.achievementSectionView
            .addSubview(components.achievementLabel)
    }
}

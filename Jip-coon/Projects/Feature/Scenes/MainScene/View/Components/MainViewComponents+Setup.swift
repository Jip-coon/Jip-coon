//
//  MainViewComponents+Setup.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - Data Setup Methods

extension MainViewComponents {

    // MARK: - 데이터 설정 메서드들

    /// 내 담당 할일 데이터 설정
    public func setupMyTasks(
        with quests: [Quest],
        familyMembers: [User] = [],
        onMyTaskTap: ((Quest) -> Void)? = nil
    ) {
        self.myTasks = Array(quests.prefix(10))  // 최대 10개
        self.familyMembers = familyMembers
        self.onMyTaskTap = onMyTaskTap
        myTasksCollectionView.reloadData()

        // 컬렉션뷰 높이 업데이트
        updateMyTasksCollectionViewHeight()
    }

    /// 빠른 액션 데이터 설정
    public func setupQuickActions(
        onQuickActionTap: ((QuickAction) -> Void)? = nil
    ) {
        self.onQuickActionTap = onQuickActionTap
        quickActionsCollectionView.reloadData()
    }

    /// 최근 활동 데이터 설정
    public func setupRecentActivities(
        with activities: [String],
        onRecentActivityTap: (
            (RecentActivity) -> Void
        )? = nil
    ) {
        self.recentActivities = activities.enumerated().map { index, activity in
            let time = index == 0 ? "30분 전" : "1시간 전"
            return RecentActivity.fromString(activity, time: time)
        }
        self.onRecentActivityTap = onRecentActivityTap
        recentActivityCollectionView.reloadData()

        // 컬렉션뷰 높이 업데이트
        updateRecentActivityCollectionViewHeight()
    }

    /// 카테고리 통계 데이터 설정
    public func setupCategoryStatsIcons(
        with stats: [(QuestCategory, Int)],
        onCategoryStatTap: (
            (QuestCategory, Int) -> Void
        )? = nil
    ) {
        let statsDict = Dictionary(
            uniqueKeysWithValues: stats.map { ($0.0.rawValue, $0.1)
            })
        self.categoryStats = statsDict

        // 클로저 변환
        self.onCategoryStatTap = {
 categoryRawValue,
 count in
            // rawValue를 QuestCategory로 다시 변환
            let category = QuestCategory(
                rawValue: categoryRawValue
            ) ?? .cleaning
            onCategoryStatTap?(category, count)
        }

        categoryStatsCollectionView.reloadData()
    }

    // MARK: - 긴급 할 일 관련 메서드들

    /// 긴급 할 일 데이터 설정
    public func setupUrgentTasks(
        with quests: [Quest],
        onUrgentTaskTap: ((Quest) -> Void)? = nil
    ) {
        let filteredQuests = quests.filter { $0.isDueToday || $0.isOverdue }

        // 우선순위별로 정렬 (마감시간이 가까운 순)
        self.urgentQuests = QuestUrgencyCalculator
            .sortQuestsByUrgency(filteredQuests)

        self.onUrgentTaskTap = onUrgentTaskTap

        // 긴급 할 일 개수 업데이트
        if urgentQuests.isEmpty {
            urgentCountLabel.text = ""
        } else {
            urgentCountLabel.text = "\(urgentQuests.count)개"
        }

        // 페이지 컨트롤 설정
        let pageCount = max(1, urgentQuests.count)
        urgentPageControl.numberOfPages = pageCount
        urgentPageControl.currentPage = 0

        // 페이지 컨트롤 터치 이벤트 설정
        urgentPageControl.addTarget(
            self,
            action: #selector(
                urgentPageControlTapped
            ),
            for: .valueChanged
        )

        // 컬렉션뷰 리로드
        urgentCollectionView.reloadData()
    }

    // MARK: - 페이지 컨트롤 액션

    @objc private func urgentPageControlTapped() {
        let page = urgentPageControl.currentPage

        let cellWidth = urgentCollectionView.frame.width
        let lineSpacing: CGFloat = 12  // minimumLineSpacing

        // 페이지당 실제 너비 = 셀 너비 + 간격
        let pageWidth = cellWidth + lineSpacing
        let offsetX = CGFloat(page) * pageWidth

        urgentCollectionView
            .setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }

}

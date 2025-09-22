//
//  MainViewComponents+DataSource.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - UICollectionViewDataSource

extension MainViewComponents: UICollectionViewDataSource {

    public func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        switch collectionView {
        case urgentCollectionView:
            return urgentQuests.isEmpty ? 1 : min(urgentQuests.count, 5)
        case myTasksCollectionView:
            return myTasks.isEmpty ? 1 : myTasks.count
        case categoryStatsCollectionView:
            let validStats = categoryStats.filter { $0.value > 0 }
            return validStats.isEmpty ? 1 : validStats.count  // 모든 카테고리 표시
        case quickActionsCollectionView:
            return quickActions.count
        case recentActivityCollectionView:
            return recentActivities.isEmpty ? 1 : recentActivities.count
        default:
            return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
    {
        switch collectionView {
        case urgentCollectionView:
            return configureUrgentCell(for: collectionView, at: indexPath)
        case myTasksCollectionView:
            return configureMyTasksCell(for: collectionView, at: indexPath)
        case categoryStatsCollectionView:
            return configureCategoryStatsCell(for: collectionView, at: indexPath)
        case quickActionsCollectionView:
            return configureQuickActionCell(for: collectionView, at: indexPath)
        case recentActivityCollectionView:
            return configureRecentActivityCell(for: collectionView, at: indexPath)
        default:
            return UICollectionViewCell()
        }
    }

    // MARK: - Cell Configuration Methods

    private func configureUrgentCell(for collectionView: UICollectionView, at indexPath: IndexPath)
    -> UICollectionViewCell
    {
        if urgentQuests.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyUrgentTaskCollectionViewCell.identifier, for: indexPath)
            return cell
        } else {
            let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: UrgentTaskCollectionViewCell.identifier, for: indexPath)
            as! UrgentTaskCollectionViewCell

            let quest = urgentQuests[indexPath.item]
            let urgencyLevel = QuestUrgencyCalculator.determineUrgencyLevel(for: quest)

            cell.configure(with: quest, urgencyLevel: urgencyLevel) { [weak self] in
                self?.onUrgentTaskTap?(quest)
            }

            return cell
        }
    }

    private func configureMyTasksCell(for collectionView: UICollectionView, at indexPath: IndexPath)
    -> UICollectionViewCell
    {
        if myTasks.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyMyTasksCollectionViewCell.identifier, for: indexPath)
            return cell
        } else {
            let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: MyTasksCollectionViewCell.identifier, for: indexPath)
            as! MyTasksCollectionViewCell

            let quest = myTasks[indexPath.item]

            cell.configure(with: quest) { [weak self] in
                self?.onMyTaskTap?(quest)
            }

            return cell
        }
    }

    private func configureCategoryStatsCell(
        for collectionView: UICollectionView, at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let validStats = categoryStats.filter { $0.value > 0 }.sorted { $0.value > $1.value }

        if validStats.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyCategoryStatsCollectionViewCell.identifier, for: indexPath)
            return cell
        } else {
            let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryStatsCollectionViewCell.identifier, for: indexPath)
            as! CategoryStatsCollectionViewCell

            let (key, count) = validStats[indexPath.item]
            if let info = CategoryInfo.categoryMapping[key] {
                cell.configure(emoji: info.emoji, name: info.name, count: count, color: info.color) {
                    [weak self] in
                    self?.onCategoryStatTap?(key, count)
                }
            }

            return cell
        }
    }

    private func configureQuickActionCell(
        for collectionView: UICollectionView, at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
        collectionView.dequeueReusableCell(
            withReuseIdentifier: QuickActionCollectionViewCell.identifier, for: indexPath)
        as! QuickActionCollectionViewCell

        let action = quickActions[indexPath.item]

        cell.configure(with: action) { [weak self] in
            self?.onQuickActionTap?(action)
        }

        return cell
    }

    private func configureRecentActivityCell(
        for collectionView: UICollectionView, at indexPath: IndexPath
    ) -> UICollectionViewCell {
        if recentActivities.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyRecentActivityCollectionViewCell.identifier, for: indexPath)
            return cell
        } else {
            let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: RecentActivityCollectionViewCell.identifier, for: indexPath)
            as! RecentActivityCollectionViewCell

            let activity = recentActivities[indexPath.item]

            cell.configure(with: activity) { [weak self] in
                self?.onRecentActivityTap?(activity)
            }

            return cell
        }
    }
}

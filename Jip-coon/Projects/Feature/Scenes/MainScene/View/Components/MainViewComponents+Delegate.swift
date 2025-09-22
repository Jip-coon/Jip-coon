//
//  MainViewComponents+Delegate.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

extension MainViewComponents: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch collectionView {
        case urgentCollectionView:
            let cellWidth = collectionView.frame.width
            return CGSize(width: cellWidth, height: 60)
        case myTasksCollectionView:
            let width = collectionView.frame.width
            return CGSize(width: width, height: 80)
        case categoryStatsCollectionView:
            return CGSize(width: 70, height: 80)
        case quickActionsCollectionView:
            let totalWith = collectionView.frame.width
            let itemWidth = totalWith - 24
            return CGSize(width: itemWidth/4, height: 60)
        case recentActivityCollectionView:
            let width = collectionView.frame.width
            return CGSize(width: width, height: 60)
        default:
            return CGSize(width: 100, height: 100)
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        switch collectionView {
        case myTasksCollectionView:
            return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        case categoryStatsCollectionView:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        case recentActivityCollectionView:
            return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == urgentCollectionView else { return }
        updateUrgentPageIndicator(for: scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        guard scrollView == urgentCollectionView, !decelerate else { return }
        updateUrgentPageIndicator(for: scrollView)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == urgentCollectionView else { return }
        updateUrgentPageIndicator(for: scrollView)
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView, withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard scrollView == urgentCollectionView else { return }

        let cellWidth = scrollView.frame.width
        let lineSpacing: CGFloat = 12
        let pageWidth = cellWidth + lineSpacing

        let targetX = targetContentOffset.pointee.x
        let page = round(targetX / pageWidth)
        let snappedX = page * pageWidth

        let maxOffset = max(0, CGFloat(urgentPageControl.numberOfPages - 1) * pageWidth)
        targetContentOffset.pointee.x = max(0, min(snappedX, maxOffset))
    }

    // MARK: - Helper Methods

    private func updateUrgentPageIndicator(for scrollView: UIScrollView) {
        let currentPage = calculateCurrentPage(for: scrollView)

        if urgentPageControl.currentPage != currentPage {
            urgentPageControl.currentPage = currentPage
        }
    }

    private func calculateCurrentPage(for scrollView: UIScrollView) -> Int {
        let cellWidth = scrollView.frame.width
        let lineSpacing: CGFloat = 12
        let pageWidth = cellWidth + lineSpacing
        let offsetX = scrollView.contentOffset.x + (pageWidth / 2)
        let currentPage = Int(offsetX / pageWidth)
        return max(0, min(currentPage, urgentPageControl.numberOfPages - 1))
    }
}

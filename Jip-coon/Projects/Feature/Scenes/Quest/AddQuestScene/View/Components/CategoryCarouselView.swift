//
//  CategoryCarouselView.swift
//  Feature
//
//  Created by 예슬 on 9/9/25.
//

import Core
import UIKit

final class CategoryCarouselView: UIView {
    private var previousCellIndex = 0
    private var focusedIndex: Int = 0
    private var didInitialView = false
    var onCategorySelected: ((QuestCategory) -> Void)?
    
    private var didInitialScroll = false
    private let focusedCellWidth: CGFloat = 79
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 63, height: 100)
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        let uICollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        uICollectionView.showsHorizontalScrollIndicator = false
        uICollectionView.translatesAutoresizingMaskIntoConstraints = false
        uICollectionView
            .register(
                CategoryCarouselViewCell.self,
                forCellWithReuseIdentifier: CategoryCarouselViewCell.identifier
            )
        return uICollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insetX = (collectionView.bounds.width - focusedCellWidth) / 2
        
        if collectionView.contentInset.left != insetX {
            collectionView.contentInset = UIEdgeInsets(
                top: 0,
                left: insetX,
                bottom: 0,
                right: insetX
            )
            collectionView.decelerationRate = .fast
        }
        
        if !didInitialScroll && QuestCategory.allCases.count > focusedIndex {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.scrollToCenterOffset(
                    for: self.focusedIndex,
                    animated: false
                )
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.didInitialScroll = true
                
                let indexPath = IndexPath(item: self.focusedIndex, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? CategoryCarouselViewCell {
                    cell.updateLayout(isFocused: true)
                }
            }
        }
    }
    
    private func setupView() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setInitialCategory(_ category: QuestCategory) {
        if let index = QuestCategory.allCases.firstIndex(of: category) {
            focusedIndex = index
            previousCellIndex = index
            didInitialScroll = false
            collectionView.reloadData()
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
        }
    }
    
    private func scrollToCenterOffset(for index: Int, animated: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        
        guard index < collectionView.numberOfItems(inSection: 0) else { return }
        
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            collectionView
                .scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: animated
                )
            return
        }
        
        let cellCenter = attributes.center.x
        let halfWidth = collectionView.bounds.width / 2
        
        let targetOffset = cellCenter - halfWidth
        
        let maxOffset = collectionView.contentSize.width + collectionView.contentInset.right - collectionView.bounds.width
        let finalOffset = max(min(targetOffset, maxOffset), -collectionView.contentInset.left)
        
        collectionView.setContentOffset(CGPoint(x: finalOffset, y: 0), animated: animated)
    }
    
    private func updateFocusedCell() {
        // 중앙 좌표 계산 (스크롤뷰의 중앙점)
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerPoint = CGPoint(x: centerX, y: collectionView.bounds.midY)
        
        // 중앙에 가장 가까운 indexPath 찾기
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            let newFocusedIndex = indexPath.item
            
            if focusedIndex != newFocusedIndex {
                
                if let prevCell = collectionView.cellForItem(at: IndexPath(item: focusedIndex, section: 0)) as? CategoryCarouselViewCell {
                    prevCell.updateLayout(isFocused: false)
                }
                
                focusedIndex = newFocusedIndex
                previousCellIndex = newFocusedIndex
                collectionView.collectionViewLayout.invalidateLayout()
                
                if let newCell = collectionView.cellForItem(at: indexPath) as? CategoryCarouselViewCell {
                    newCell.updateLayout(isFocused: true)
                }
                
                let category = QuestCategory.allCases[focusedIndex]
                onCategorySelected?(category)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension CategoryCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QuestCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCarouselViewCell.identifier, for: indexPath) as? CategoryCarouselViewCell else {
            return UICollectionViewCell()
        }
        
        let category = QuestCategory.allCases[indexPath.item]
        cell.configure(with: category)
        cell.updateLayout(isFocused: indexPath.item == focusedIndex)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollToCenterOffset(for: indexPath.item, animated: true)
        
        if focusedIndex != indexPath.item {
            focusedIndex = indexPath.item
            previousCellIndex = indexPath.item
            updateFocusedCell()
        }
    }
}

// MARK: - 내용UICollectionViewDelegateFlowLayout

extension CategoryCarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == focusedIndex {
            return CGSize(width: 79, height: 109)  // 포커스된 셀
        } else {
            return CGSize(width: 63, height: 99)   // 기본 셀
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CategoryCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 중앙 좌표 계산 (컬렉션뷰의 보이는 영역 중앙 + 현재 오프셋)
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerPoint = CGPoint(x: centerX, y: collectionView.bounds.midY)
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            let newFocusedIndex = indexPath.item
            
            if focusedIndex != newFocusedIndex {
                
                if let prevCell = collectionView.cellForItem(at: IndexPath(item: focusedIndex, section: 0)) as? CategoryCarouselViewCell {
                    prevCell.updateLayout(isFocused: false)
                }
                
                focusedIndex = newFocusedIndex
                
                collectionView.collectionViewLayout.invalidateLayout()
                
                if let newCell = collectionView.cellForItem(at: indexPath) as? CategoryCarouselViewCell {
                    newCell.updateLayout(isFocused: true)
                }
                
                let category = QuestCategory.allCases[focusedIndex]
                onCategorySelected?(category)
            }
        }
    }
    
    // 스크롤 종료 시, 포커스된 셀 중앙정렬
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let proposedX = targetContentOffset.pointee.x
        let boundsWidth = collectionView.bounds.width
        let proposedCenterX = proposedX + boundsWidth / 2
        
        let searchRect = CGRect(
            x: max(proposedX - boundsWidth, -collectionView.contentInset.left),
            y: 0,
            width: boundsWidth * 2,
            height: collectionView.bounds.height
        )
        
        guard let attributesArray = collectionView.collectionViewLayout.layoutAttributesForElements(
            in: searchRect
        ),
              !attributesArray.isEmpty else { return }
        
        let nearest = attributesArray.min {a, b in
            abs(a.center.x - proposedCenterX) < abs(
                b.center.x - proposedCenterX
            )
        }
        
        guard let itemCenterX = nearest?.center.x else { return }
        
        var newX = itemCenterX - boundsWidth / 2
        let maxOffset = collectionView.contentSize.width + collectionView.contentInset.right - boundsWidth
        newX = max(min(newX, maxOffset), -collectionView.contentInset.left)
        targetContentOffset.pointee = CGPoint(x: newX, y: 0)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCenterOffset(for: focusedIndex, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenterOffset(for: focusedIndex, animated: true)
    }
}

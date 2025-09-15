//
//  CategoryCarouselView.swift
//  Feature
//
//  Created by 예슬 on 9/9/25.
//

import UIKit
import Core

final class CategoryCarouselView: UIView {
    private var previousCellIndex = 0
    private var focusedIndex: Int = 2
    private var didInitialView = false
    var onCategorySelected: ((QuestCategory) -> Void)?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 63, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let uICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        uICollectionView.showsHorizontalScrollIndicator = false
        uICollectionView.translatesAutoresizingMaskIntoConstraints = false
        uICollectionView.register(CategoryCarouselViewCell.self, forCellWithReuseIdentifier: CategoryCarouselViewCell.identifier)
        return uICollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.layoutIfNeeded()
        
        // 첫 번째 셀과 마지막 셀도 화면 중앙에 올 수 있도록
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let insetX = (collectionView.bounds.width - layout.itemSize.width) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        collectionView.decelerationRate = .fast
        
        // 초기 포커스 셀 레이아웃 적용
        if let cell = collectionView.cellForItem(at: IndexPath(item: focusedIndex, section: 0)) as? CategoryCarouselViewCell {
            cell.updateLayout(isFocused: true)
            didInitialView = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

extension CategoryCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return QuestCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCarouselViewCell.identifier, for: indexPath) as! CategoryCarouselViewCell
        let category = QuestCategory.allCases[indexPath.item]
        cell.configure(with: category)
        return cell
    }
}

extension CategoryCarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == focusedIndex {
            return CGSize(width: 79, height: 109)  // 포커스된 셀
        } else {
            return CGSize(width: 63, height: 99)   // 기본 셀
        }
    }
}

extension CategoryCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard didInitialView else {
            didInitialView = false
            return
        }
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let centerPoint = CGPoint(x: centerX, y: scrollView.bounds.midY)
        
        // 중앙에 가장 가까운 indexPath 찾기
        if let indexPath = collectionView.indexPathForItem(at: centerPoint),
           let cell = collectionView.cellForItem(at: indexPath) as? CategoryCarouselViewCell {
            if focusedIndex != indexPath.item {
                focusedIndex = indexPath.item
                collectionView.performBatchUpdates(nil)  // 레이아웃 갱신
            }
            
            // 새로운 중앙 셀 → 확대
            if previousCellIndex != indexPath.item {
                // 이전 셀 → 축소
                if let prevCell = collectionView.cellForItem(at: IndexPath(item: previousCellIndex, section: 0)) as? CategoryCarouselViewCell {
                    prevCell.updateLayout(isFocused: false)
                }
                
                cell.updateLayout(isFocused: true)
                previousCellIndex = indexPath.item
                
                // 뷰모델에 카테고리 저장
                let category = QuestCategory.allCases[focusedIndex]
                onCategorySelected?(category)
            }
        }
    }
}

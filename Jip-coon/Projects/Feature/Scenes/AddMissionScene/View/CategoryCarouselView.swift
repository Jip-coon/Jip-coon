//
//  CategoryCarouselView.swift
//  Feature
//
//  Created by 예슬 on 9/9/25.
//

import UIKit
import Core

final class CategoryCarouselView: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 63, height: 100)
        
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

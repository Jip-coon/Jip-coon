//
//  CategoryCarouselViewCell.swift
//  Feature
//
//  Created by 예슬 on 9/9/25.
//

import UIKit
import UI

class CategoryCarouselViewCell: UICollectionViewCell {
    static let identifier = CategoryCarouselViewCell.self.description()
    
    private let categoryIcon: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 36, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
    }
}

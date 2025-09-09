//
//  CategoryCarouselViewCell.swift
//  Feature
//
//  Created by 예슬 on 9/9/25.
//

import UIKit
import UI

final class CategoryCarouselViewCell: UICollectionViewCell {
    static let identifier = CategoryCarouselViewCell.self.description()
    
    private let categoryIcon: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        label.backgroundColor = .orange3
        label.text = "🧑‍🍳"
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.text = "요리"
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
        contentView.addSubview(categoryIcon)
        contentView.addSubview(categoryLabel)
        
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryIcon.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryIcon.widthAnchor.constraint(equalToConstant: 63),
            categoryIcon.heightAnchor.constraint(equalToConstant: 64),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryIcon.bottomAnchor, constant: 18),
            categoryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(emoji: String, color: UIColor, category: String) {
        categoryIcon.text = emoji
        categoryIcon.backgroundColor = color
        categoryLabel.text = category
    }
}

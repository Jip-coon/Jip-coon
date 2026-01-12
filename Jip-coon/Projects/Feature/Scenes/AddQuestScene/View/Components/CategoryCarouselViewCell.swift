//
//  CategoryCarouselViewCell.swift
//  Feature
//
//  Created by 예슬 on 9/9/25.
//

import UIKit
import Core
import UI

final class CategoryCarouselViewCell: UICollectionViewCell {
    static let identifier = CategoryCarouselViewCell.self.description()
    private var categoryIconWidthConstraint: NSLayoutConstraint!
    private var categoryIconHeightConstraint: NSLayoutConstraint!
    private var categoryLabelTopConstraint: NSLayoutConstraint!
    
    private let categoryIcon: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .textGray
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
        
        categoryIconWidthConstraint = categoryIcon.widthAnchor
            .constraint(equalToConstant: 63)
        categoryIconHeightConstraint = categoryIcon.heightAnchor
            .constraint(equalToConstant: 63)
        categoryLabelTopConstraint = categoryLabel.topAnchor
            .constraint(equalTo: categoryIcon.bottomAnchor, constant: 18)
        
        NSLayoutConstraint.activate([
            categoryIcon.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryIcon.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),
            categoryIconWidthConstraint,
            categoryIconHeightConstraint,
            
            categoryLabelTopConstraint,
            categoryLabel.centerXAnchor
                .constraint(equalTo: contentView.centerXAnchor),
            categoryLabel.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with category: QuestCategory) {
        categoryIcon.text = category.emoji
        categoryIcon.backgroundColor = UIColor
            .questCategoryColor(for: category.backgroundColor)
        categoryLabel.text = category.displayName
    }
    
    func updateLayout(isFocused: Bool) {
        if isFocused {
            categoryIconWidthConstraint.constant = 79
            categoryIconHeightConstraint.constant = 80
            categoryLabelTopConstraint.constant = 10
            categoryIcon.font = .systemFont(ofSize: 36)
            categoryLabel.font = .pretendard(ofSize: 16, weight: .bold)
            categoryLabel.textColor = .black
        } else {
            categoryIconWidthConstraint.constant = 63
            categoryIconHeightConstraint.constant = 64
            categoryLabelTopConstraint.constant = 18
            categoryIcon.font = .systemFont(ofSize: 20)
            categoryLabel.font = .pretendard(ofSize: 14, weight: .regular)
            categoryLabel.textColor = .textGray
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
}

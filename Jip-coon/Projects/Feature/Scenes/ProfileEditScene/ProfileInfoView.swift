//
//  ProfileInfoView.swift
//  Feature
//
//  Created by 예슬 on 11/27/25.
//

import UI
import UIKit

final class ProfileInfoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .textGray
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 12
        self.backgroundColor = .gray1
        
        self.addSubview(titleLabel)
        self.addSubview(infoLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 9),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -9),
        ])
    }
    
    func updateInfo(_ text: String) {
        self.infoLabel.text = text
    }
}

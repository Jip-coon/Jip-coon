//
//  TextFieldComponent.swift
//  Feature
//
//  Created by 예슬 on 9/11/25.
//

import UIKit
import UI

final class TextFieldComponent: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .pretendard(ofSize: 16, weight: .regular)
        textField.setPlaceholder(fontSize: 14)
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 10
        textField.leftPadding(of: 10)
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(titleLabel)
        addSubview(textField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 13),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    func configure(title: String, placeholder: String) {
        titleLabel.text = title
        textField.placeholder = placeholder
    }
    
}

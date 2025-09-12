//
//  InfoRowView.swift
//  Feature
//
//  Created by 예슬 on 9/11/25.
//

import UIKit
import UI

enum InfoRowButtonStyle {
    case plain
    case capsule
}

final class InfoRowView: UIView {
    private var leadingView: UIView
    private var buttonStyle: InfoRowButtonStyle = .plain
    private let tapGesture = UITapGestureRecognizer()
    var onTap: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")?.applyingSymbolConfiguration(.init(pointSize: 14, weight: .regular))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let valueContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let valueStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(leading: UIView, title: String, value: String, buttonStyle: InfoRowButtonStyle = .plain) {
        self.leadingView = leading
        self.buttonStyle = buttonStyle
        super.init(frame: .zero)
        
        setupView()
        setupButtonStyle(buttonStyle)
        
        titleLabel.text = title
        valueLabel.text = value
        
        tapGesture.addTarget(self, action: #selector(tapButton))
        valueStack.addGestureRecognizer(tapGesture)
        valueStack.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        
        valueContainerView.addSubview(valueLabel)
        
        valueStack.addArrangedSubview(valueContainerView)
        valueStack.addArrangedSubview(chevronImageView)
        
        stackView.addArrangedSubview(titleStack)
        stackView.addArrangedSubview(valueStack)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: valueContainerView.topAnchor, constant: 5),
            valueLabel.leadingAnchor.constraint(equalTo: valueContainerView.leadingAnchor, constant: 9),
            valueLabel.trailingAnchor.constraint(equalTo: valueContainerView.trailingAnchor, constant: -9),
            valueLabel.bottomAnchor.constraint(equalTo: valueContainerView.bottomAnchor, constant: -5)
        ])
    }
    
    private func setupButtonStyle(_ style: InfoRowButtonStyle) {
        switch style {
            case .plain:
                valueContainerView.backgroundColor = .clear
                valueContainerView.layer.cornerRadius = 0
            case .capsule:
                valueContainerView.backgroundColor = .blue1
                valueContainerView.layer.cornerRadius = 14
                valueLabel.font = .pretendard(ofSize: 14, weight: .semibold)
        }
    }
    
    @objc private func tapButton() {
        onTap?()
    }
    
    func setValueText(_ text: String) {
        valueLabel.text = text
    }
}

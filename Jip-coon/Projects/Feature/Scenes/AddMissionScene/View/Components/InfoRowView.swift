//
//  InfoRowView.swift
//  Feature
//
//  Created by 예슬 on 9/11/25.
//

import UIKit
import UI

final class InfoRowView: UIView {
    private var leadingView: UIView
    var onTap: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let infoValueButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.right")?.applyingSymbolConfiguration(.init(pointSize: 14, weight: .regular))
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = .black
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .pretendard(ofSize: 16, weight: .regular)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return button
    }()
    
    private let titleStack: UIStackView = {
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
        return stackView
    }()
    
    init(leading: UIView, title: String, value: String) {
        self.leadingView = leading
        super.init(frame: .zero)
        
        setupView()
        
        titleLabel.text = title
        infoValueButton.setTitle(value, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(titleStack)
        stackView.addArrangedSubview(infoValueButton)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func tapButton() {
        onTap?()
    }
    
    func setValueText(_ text: String) {
        infoValueButton.setTitle(text, for: .normal)
    }
}

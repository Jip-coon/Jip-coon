//
//  InfoRowView.swift
//  Feature
//
//  Created by 예슬 on 9/11/25.
//

import UIKit
import UI

enum InfoRowButtonStyle {
    case rightArrowAction   // Text + chevron -> 여러가지...
    case rightArrowMenu     // Text + chevron -> UIMenu
    case capsuleMenu        // 캡슐 모양 버튼 -> UIMenu
    case textOnly           // Text (연결된 액션 없음)
}

final class InfoRowView: UIView {
    private var buttonStyle: InfoRowButtonStyle = .rightArrowAction
    private let colors: [UIColor] = [
        .blue1,
        .blue2,
        .brown1,
        .green1,
        .orange3,
        .purple1,
        .red1,
        .yellow1
    ]
    var onTap: (() -> Void)?
    
    // 이모지 + 타이틀
    private var leadingView: UIView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    // 내용
    private var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var valueText: String {
        return actionButton.titleLabel?.text ?? ""
    }
    
    init(
        leading: UIView,
        title: String,
        value: String,
        buttonStyle: InfoRowButtonStyle = .rightArrowAction
    ) {
        self.leadingView = leading
        self.buttonStyle = buttonStyle
        super.init(frame: .zero)
        
        setupView()
        setupButtonStyle(buttonStyle, with: value)
        
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(titleStack)
        stackView.addArrangedSubview(actionButton)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupButtonStyle(
        _ style: InfoRowButtonStyle,
        with text: String
    ) {
        var config = UIButton.Configuration.plain()
        
        config.title = text
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = .black
        
        switch style {
        case .rightArrowAction:    // (기본 스타일: Label + Chevron) + Action
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .pretendard(ofSize: 16, weight: .regular)
                return outgoing
            }
            config.image = UIImage(systemName: "chevron.right")?
                .applyingSymbolConfiguration(
                    .init(pointSize: 14, weight: .regular)
                )
            config.contentInsets = .zero
                
            actionButton
                .addTarget(
                    self,
                    action: #selector(tapButton),
                    for: .touchUpInside
                )
                
        case .capsuleMenu:  // 캡슐 + 메뉴
            config.background.backgroundColor = colors.randomElement()
            config.background.cornerRadius = 14
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 9,
                bottom: 5,
                trailing: 9
            )
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .pretendard(ofSize: 14, weight: .semibold)
                return outgoing
            }
                
            actionButton.showsMenuAsPrimaryAction = true    // 메뉴를 기본 액션으로
                
        case .rightArrowMenu:    // 기본 + 메뉴
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .pretendard(ofSize: 16, weight: .regular)
                return outgoing
            }
            config.image = UIImage(systemName: "chevron.right")?
                .applyingSymbolConfiguration(
                    .init(pointSize: 14, weight: .regular)
                )
            config.contentInsets = .zero
                
            actionButton.showsMenuAsPrimaryAction = true
            
        case .textOnly:
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .pretendard(ofSize: 16, weight: .regular)
                return outgoing
            }
            config.contentInsets = .zero
        }
        
        actionButton.configuration = config
    }
    
    @objc private func tapButton() {
        onTap?()
    }
    
    func setValueText(_ text: String) {
        var config = actionButton.configuration
        config?.title = text
        
        if buttonStyle == .capsuleMenu {
            config?.background.backgroundColor = colors.randomElement()
        }
        actionButton.configuration = config
    }
    
    func setupMenu(_ menu: UIMenu) {
        actionButton.menu = menu
    }
    
    func updateButtonStyle(_ style: InfoRowButtonStyle, _ text: String) {
        setupButtonStyle(style, with: text)
    }
}

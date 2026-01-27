//
//  HomeFilterBar.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import UIKit

protocol HomeFilterBarDelegate: AnyObject {
    func didSelectFilter(_ filterType: HomeFilterType)
}

enum HomeFilterType: Int {
    case collection = 0
    case urgent = 1
    
    var title: String {
        switch self {
        case .collection: return "나의할일"
        case .urgent: return "긴급할일"
        }
    }
    
    var icon: String {
        switch self {
        case .collection: return "archivebox.fill"
        case .urgent: return "light.beacon.max.fill"
        }
    }
}

final class HomeFilterBar: UIView {
    
    weak var delegate: HomeFilterBarDelegate?
    
    // MARK: - Properties
    
    private var selectedFilter: HomeFilterType = .collection
    private let stackView = UIStackView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        let filterTypes: [HomeFilterType] = [.collection, .urgent]
        
        for (index, type) in filterTypes.enumerated() {
            let buttonView = createFilterButton(for: type, showSeparator: index == 0)
            stackView.addArrangedSubview(buttonView)
        }
        
        // 레이아웃 균형을 위한 더미 뷰들
        // TODO: - 승인 탭을 표시하는 것도 좋아보임
        for _ in 0..<2 {
            let dummy = UIView()
            dummy.isUserInteractionEnabled = false
            stackView.addArrangedSubview(dummy)
        }
    }
    
    private func createFilterButton(for type: HomeFilterType, showSeparator: Bool) -> UIView {
        let container = UIView()
        
        let button = UIButton(type: .system)
        button.tag = type.rawValue
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: type.icon, withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.backgroundColor = .clear
        button.layer.cornerRadius = 26
        button.layer.borderWidth = 1.5
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        // 초기 상태 설정
        updateButtonStyle(button, isSelected: type == selectedFilter)
        
        let label = UILabel()
        label.text = type.title
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        
        container.addSubview(button)
        container.addSubview(label)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 52),
            button.heightAnchor.constraint(equalToConstant: 52),
            
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ]
        
        if showSeparator {
            let separator = UIView()
            separator.backgroundColor = .systemGray4
            container.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                separator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                separator.widthAnchor.constraint(equalToConstant: 1),
                separator.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let newFilter = HomeFilterType(rawValue: sender.tag) else { return }
        selectedFilter = newFilter
        delegate?.didSelectFilter(newFilter)
        updateAllButtons()
    }
    
    // MARK: - Helper
    
    private func updateAllButtons() {
        for case let container in stackView.arrangedSubviews {
            if let button = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                let isSelected = button.tag == selectedFilter.rawValue
                updateButtonStyle(button, isSelected: isSelected)
            }
        }
    }
    
    private func updateButtonStyle(_ button: UIButton, isSelected: Bool) {
        button.layer.borderColor = isSelected ? UIColor.label.cgColor : UIColor.systemGray5.cgColor
    }
    
    /// 다크모드 대응 등으로 인해 외부에서 갱신이 필요할 때 호출
    func refreshStyles() {
        updateAllButtons()
    }
}

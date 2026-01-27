//
//  FilterButtonView.swift
//  Feature
//
//  Created by 예슬 on 1/19/26.
//

import UI
import UIKit

final class FilterButtonView: UIView {
    
    // 필터 옵션 정의
    enum FilterOption: String, CaseIterable {
        case all = "전체"
        case pending = "대기중"
        case progressing = "진행중"
        case completed = "완료"
        
        // 개별 옵션들만 따로 필터링 (전체 제외)
        static var individualOptions: [FilterOption] {
            return allCases.filter { $0 != .all }
        }
    }
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    
    // 현재 선택된 상태 관리
    private var selectedOptions: Set<FilterOption> = [.all] {
        didSet {
            buttons.forEach { button in
                guard let title = button.configuration?.title,
                      let option = FilterOption(rawValue: title) else { return }
                
                button.isSelected = selectedOptions.contains(option)
                button.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var onFilterChanged: ((Set<FilterOption>) -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 버튼 생성 및 추가
        FilterOption.allCases.forEach { option in
            let button = createButton(for: option)
            button.tag = FilterOption.allCases.firstIndex(of: option) ?? 0
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func filterTapped(_ sender: UIButton) {
        guard let title = sender.configuration?.title,
              let tappedOption = FilterOption(rawValue: title) else {
            print("로그: 옵션을 찾을 수 없음")
            return
        }
        
        if tappedOption == .all {
            // "전체"를 누르면 다른 거 다 끄고 전체만 활성화
            selectedOptions = [.all]
        } else {
            // 개별 버튼을 누르는 순간 "전체"는 일단 해제
            selectedOptions.remove(.all)
            
            // 이미 선택된 걸 누르면 해제, 아니면 추가 (토글)
            if selectedOptions.contains(tappedOption) {
                selectedOptions.remove(tappedOption)
            } else {
                selectedOptions.insert(tappedOption)
            }
            
            // 3개가 다 선택되었거나, 아무것도 선택되지 않았다면 다시 "전체"
            let individualFilters = FilterOption.individualOptions
            let allIndividualSelected = individualFilters.allSatisfy { selectedOptions.contains($0) }
            
            if selectedOptions.isEmpty || allIndividualSelected {
                selectedOptions = [.all]
            }
        }
        
        onFilterChanged?(selectedOptions)
    }
    
    private func createButton(for option: FilterOption) -> UIButton {
        var config = UIButton.Configuration.plain()
        
        config.title = option.rawValue
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        var titleAttr = AttributedString(option.rawValue)
        titleAttr.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = titleAttr
        
        let button = UIButton(configuration: config)
        button.isSelected = (option == .all)
        
        button.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            let isSelected = button.isSelected
            
            updatedConfig?.background.backgroundColor = isSelected ? .black : .gray2
            updatedConfig?.baseForegroundColor = isSelected ? .white : .black
            updatedConfig?.background.cornerRadius = 8
            
            button.configuration = updatedConfig
        }
        
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        return button
    }
}

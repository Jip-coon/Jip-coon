//
//  MainTabBar.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import UIKit

/// 커스텀 하단 네비게이션 탭바
final class MainTabBar: UIView {
    
    // MARK: - Properties
    
    /// 탭 선택
    var onTabSelected: ((Int) -> Void)?
    
    /// 중앙 플러스 버튼 탭
    var onPlusButtonTapped: (() -> Void)?
    
    /// 현재 선택된 탭
    private var selectedTab: Int = 0
    
    /// 선택 인디케이터
    private var navigationIndicator: UIView?
    private var navigationIndicatorLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    
    /// 중앙 플러스 버튼
    private lazy var centerPlusButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 10
        
        setupNavigationButtons()
    }
    
    /// 하단 네비게이션 버튼 생성 및 추가
    private func setupNavigationButtons() {
        // 통합 그룹 생성
        let navigationGroup = createUnifiedNavigationGroup()
        navigationGroup.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(navigationGroup)
        
        // 중앙 플러스 버튼 추가
        centerPlusButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerPlusButton)
        
        NSLayoutConstraint.activate([
            // 통합 그룹
            navigationGroup.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            navigationGroup.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            navigationGroup.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            
            // 중앙 플러스 버튼
            centerPlusButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPlusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            centerPlusButton.widthAnchor.constraint(equalToConstant: 56),
            centerPlusButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    /// 통합 네비게이션 그룹 생성
    private func createUnifiedNavigationGroup() -> UIView {
        let groupContainer = UIView()
        groupContainer.backgroundColor = .white
        groupContainer.layer.cornerRadius = 28
        groupContainer.layer.shadowColor = UIColor.black.cgColor
        groupContainer.layer.shadowOpacity = 0.08
        groupContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        groupContainer.layer.shadowRadius = 8
        
        // 선택 인디케이터 생성
        let indicator = UIView()
        indicator.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        indicator.layer.cornerRadius = 22
        indicator.translatesAutoresizingMaskIntoConstraints = false
        groupContainer.addSubview(indicator)
        navigationIndicator = indicator
        
        // 모든 버튼 아이콘 정의
        let allIcons: [(icon: String, tag: Int)] = [
            ("house.fill", 0),          // 홈
            ("text.page.fill", 1),     // 전체 퀘스트
            ("trophy.fill", 3),        // 랭킹
            ("gear", 4)                // 설정
        ]
        
        // 좌측 스택뷰 (홈, 전체 퀘스트)
        let leftStackView = UIStackView()
        leftStackView.axis = .horizontal
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = 8
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 우측 스택뷰 (랭킹, 설정)
        let rightStackView = UIStackView()
        rightStackView.axis = .horizontal
        rightStackView.distribution = .fillEqually
        rightStackView.spacing = 8
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 생성 및 스택뷰에 추가
        for (index, iconData) in allIcons.enumerated() {
            let buttonContainer = UIView()
            
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            button.setImage(UIImage(systemName: iconData.icon, withConfiguration: config), for: .normal)
            button.tintColor = .label
            button.tag = iconData.tag
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            
            buttonContainer.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
                button.widthAnchor.constraint(equalToConstant: 40),
                button.heightAnchor.constraint(equalToConstant: 40),
                buttonContainer.widthAnchor.constraint(equalToConstant: 56),
                buttonContainer.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            if index < 2 {
                leftStackView.addArrangedSubview(buttonContainer)
            } else {
                rightStackView.addArrangedSubview(buttonContainer)
            }
        }
        
        groupContainer.addSubview(leftStackView)
        groupContainer.addSubview(rightStackView)
        
        let initialLeadingConstant: CGFloat = 8
        let indicatorLeadingConstraint = indicator.leadingAnchor.constraint(equalTo: groupContainer.leadingAnchor, constant: initialLeadingConstant)
        navigationIndicatorLeadingConstraint = indicatorLeadingConstraint
        
        NSLayoutConstraint.activate([
            // 좌측 스택뷰
            leftStackView.topAnchor.constraint(equalTo: groupContainer.topAnchor, constant: 4),
            leftStackView.leadingAnchor.constraint(equalTo: groupContainer.leadingAnchor, constant: 8),
            leftStackView.bottomAnchor.constraint(equalTo: groupContainer.bottomAnchor, constant: -4),
            
            // 우측 스택뷰
            rightStackView.topAnchor.constraint(equalTo: groupContainer.topAnchor, constant: 4),
            rightStackView.trailingAnchor.constraint(equalTo: groupContainer.trailingAnchor, constant: -8),
            rightStackView.bottomAnchor.constraint(equalTo: groupContainer.bottomAnchor, constant: -4),
            
            // 인디케이터 제약
            indicator.topAnchor.constraint(equalTo: groupContainer.topAnchor, constant: 4),
            indicatorLeadingConstraint,
            indicator.widthAnchor.constraint(equalToConstant: 56),
            indicator.heightAnchor.constraint(equalToConstant: 44),
            
            // 그룹 컨테이너 높이
            groupContainer.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        return groupContainer
    }
    
    // MARK: - Actions
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedTab = sender.tag
        updateIndicatorPosition()
        onTabSelected?(sender.tag)
    }
    
    @objc private func plusButtonTapped() {
        onPlusButtonTapped?()
    }
    
    // MARK: - Public Methods
    
    /// 선택된 탭 업데이트
    func selectTab(at index: Int) {
        selectedTab = index
        updateIndicatorPosition()
    }
    
    /// 인디케이터 위치 업데이트
    private func updateIndicatorPosition() {
        guard let constraint = navigationIndicatorLeadingConstraint,
              let indicator = navigationIndicator,
              let superview = indicator.superview else { return }
        
        let position: Int
        switch selectedTab {
            case 0: position = 0  // 홈
            case 1: position = 1  // 전체 퀘스트
            case 3: position = 2  // 랭킹
            case 4: position = 3  // 설정
            default: position = 0
        }
        
        let leadingConstant = calculateLeadingConstant(for: position, totalWidth: superview.bounds.width)
        
        constraint.constant = leadingConstant
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut
        ) {
            indicator.superview?.layoutIfNeeded()
        }
    }
    
    /// 인디케이터 위치 계산
    private func calculateLeadingConstant(for position: Int, totalWidth: CGFloat) -> CGFloat {
        let itemWidth: CGFloat = 56
        let itemSpacing: CGFloat = 8
        let horizontalPadding: CGFloat = 8
        
        let itemFullWidth = itemWidth + itemSpacing
        
        if position < 2 {
            // 왼쪽 그룹 (인덱스 0, 1)
            return horizontalPadding + CGFloat(position) * itemFullWidth
        } else {
            // 오른쪽 그룹 (인덱스 2, 3)
            // 오른쪽 그룹 시작 위치 = 전체 너비 - (우측 여백 + 버튼 2개 너비 + 버튼 사이 간격)
            let rightGroupWidth = (itemWidth * 2) + itemSpacing
            let rightGroupStart = totalWidth - horizontalPadding - rightGroupWidth
            
            // 오른쪽 그룹 내에서의 인덱스 (0부터 시작하도록 조정)
            let indexInRightGroup = CGFloat(position - 2)
            
            return rightGroupStart + indexInRightGroup * itemFullWidth
        }
    }
}

//
//  UnderlineSegmentControl.swift
//  Feature
//
//  Created by 예슬 on 1/19/26.
//

import UI
import UIKit

final class UnderlineSegmentControl: UIView {
    
    private let stackView = UIStackView()
    private let underlineView = UIView()
    private var buttons: [UIButton] = []
    
    private(set) var selectedIndex: Int = 0
    var onIndexChanged: ((Int) -> Void)?
    
    private var underlineLeadingConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!
    
    init(titles: [String]) {
        super.init(frame: .zero)
        setup(titles: titles)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup(titles: [String]) {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        
        addSubview(stackView)
        addSubview(underlineView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        
        underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor
                .constraint(equalTo: topAnchor),
            stackView.leadingAnchor
                .constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor
                .constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor
                .constraint(equalTo: bottomAnchor),
            
            underlineView.bottomAnchor
                .constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor
                .constraint(equalToConstant: 1),
            underlineLeadingConstraint,
            underlineWidthConstraint
        ])
        
        underlineView.backgroundColor = .black
        
        titles.enumerated().forEach { index, title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            button.setTitleColor(.gray2, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.backgroundColor = .clear
            button.tintColor = .clear
            button.tag = index
            button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        select(index: 0, animated: false)
    }
    
    @objc private func tap(_ sender: UIButton) {
        select(index: sender.tag, animated: true)
    }
    
    func select(index: Int, animated: Bool = true) {
        selectedIndex = index
        
        // 버튼 상태 업데이트
        buttons.enumerated().forEach { i, btn in
            btn.isSelected = (i == index)
        }
        
        moveUnderline(animated: animated)
        onIndexChanged?(index)
    }
    
    private func moveUnderline(animated: Bool) {
        guard buttons.indices.contains(selectedIndex) else { return }
        
        // 뷰의 width가 0이면 레이아웃이 아직 완료되지 않은 것이므로 업데이트 스킵
        guard bounds.width > 0 else { return }
        
        // 스택뷰가 버튼들을 제자리에 배치하도록 강제
        stackView.layoutIfNeeded()
        
        let targetButton = buttons[selectedIndex]
        // 버튼 내부 라벨의 레이아웃을 강제로 한 번 잡아서 너비 계산 오류 방지
        targetButton.layoutIfNeeded()
        
        guard let label = targetButton.titleLabel else { return }
        
        // 버튼 내 라벨의 위치를 현재 뷰(self) 기준으로 변환
        let frame = label.convert(label.bounds, to: self)
        
        // 라벨의 width가 유효한지 확인
        guard frame.width > 0 else { return }
        
        let ratio: CGFloat = 0.9
        let newWidth = frame.width * ratio
        let diff = frame.width - newWidth
        
        underlineWidthConstraint.constant = newWidth
        underlineLeadingConstraint.constant = frame.minX + (diff / 2)
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // layoutSubviews가 여러 번 호출될 수 있으므로, 
        // 유효한 bounds를 가질 때만 underline 업데이트
        if bounds.width > 0 {
            moveUnderline(animated: false)
        }
    }
    
}

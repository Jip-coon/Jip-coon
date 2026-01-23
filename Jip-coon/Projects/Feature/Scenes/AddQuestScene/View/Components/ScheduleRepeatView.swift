//
//  ScheduleRepeatView.swift
//  Feature
//
//  Created by 예슬 on 9/13/25.
//

import UIKit
import UI

final class ScheduleRepeatView: UIView {
    private let dayButtons = DayButtons()
    
    private let repeatLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .semibold)
        label.text = "반복"
        label.textColor = .label
        return label
    }()
    
    private let dayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    // 외부에서 요일 버튼 접근 가능
    subscript(day: Day) -> DayButton {
        dayButtons[day]
    }
    
    // 선택된 요일 배열
    var selectedDays: [Day] {
        Day.allCases.filter { dayButtons[$0].isSelected }
    }
    
    var onDayButtonTapped: (([Day]) -> Void)?   // 버튼 누를 시 실행될 클로저
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [repeatLabel, dayStackView].forEach { addSubview($0) }
        [repeatLabel, dayStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        dayButtons.allButtons.forEach { dayButton in
            dayStackView.addArrangedSubview(dayButton)
            dayButton
                .addTarget(
                    self,
                    action: #selector(dayButtonTapped),
                    for: .touchUpInside
                )
        }
        
        NSLayoutConstraint.activate([
            repeatLabel.topAnchor.constraint(equalTo: topAnchor),
            repeatLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            dayStackView.topAnchor
                .constraint(equalTo: repeatLabel.bottomAnchor, constant: 10),
            dayStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func dayButtonTapped(_ sender: DayButton) {
        sender.isSelected.toggle()
        onDayButtonTapped?(selectedDays)
    }
    
    /// 외부(상세뷰)에서 요일 데이터를 전달받아 UI를 갱신하는 함수
    func updateDays(_ days: Set<Day>) {
        // 모든 버튼을 일단 해제
        Day.allCases.forEach { day in
            dayButtons[day].isSelected = false
        }
        
        // 전달받은 요일에 해당하는 버튼만 선택 상태로 변경 (색상 변경됨)
        days.forEach { day in
            dayButtons[day].isSelected = true
        }
    }
}

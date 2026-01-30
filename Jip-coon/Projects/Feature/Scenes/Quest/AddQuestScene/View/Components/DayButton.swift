//
//  DayButton.swift
//  Feature
//
//  Created by 예슬 on 9/13/25.
//

import UIKit
import UI

enum Day: String, CaseIterable {
    case mon = "월"
    case tue = "화"
    case wed = "수"
    case thu = "목"
    case fri = "금"
    case sat = "토"
    case sun = "일"
    
    var weekdayIndex: Int {
        switch self {
            case .sun: return 0
            case .mon: return 1
            case .tue: return 2
            case .wed: return 3
            case .thu: return 4
            case .fri: return 5
            case .sat: return 6
        }
    }
}

final class DayButton: UIButton {
    private var day: Day
    
    init(day: Day) {
        self.day = day
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 기본 설정
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        config.background.backgroundColor = .textFieldStroke
        config.cornerStyle = .large
        config.attributedTitle = AttributedString(day.rawValue, attributes: AttributeContainer([
            .font: UIFont.pretendard(ofSize: 16, weight: .regular)
        ]))
        
        // 디바이스에 맞게 inset 변경
        let isSmallDevice = UIScreen.main.bounds.width <= 375 // iPhone SE2, 8, 13 mini width
        let verticalInset: CGFloat = isSmallDevice ? 10 : 13
        let horizontalInset: CGFloat = verticalInset + 2
        
        config.contentInsets = .init(
            top: verticalInset,
            leading: horizontalInset,
            bottom: verticalInset,
            trailing: horizontalInset
        )
        
        self.configuration = config
        
        // 버튼 배경색 변경
        self.configurationUpdateHandler = { button in
            guard var config = button.configuration else { return }
            config.background.backgroundColor = button.isSelected ? .secondaryOrange : .textFieldStroke
            button.configuration = config
        }
    }
}

struct DayButtons {
    private var buttons: [Day: DayButton] = [:]
    
    init() {
        for day in Day.allCases {
            buttons[day] = DayButton(day: day)
        }
    }
    
    subscript(day: Day) -> DayButton {
        guard let button = buttons[day] else {
            fatalError("Button for \(day.rawValue) not found")
        }
        return button
    }
    
    var allButtons: [DayButton] {
        Day.allCases.map { buttons[$0]! }
    }
}

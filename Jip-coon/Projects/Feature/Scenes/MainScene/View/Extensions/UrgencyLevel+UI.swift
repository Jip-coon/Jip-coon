//
//  UrgencyLevel+UI.swift
//  Feature
//
//  Created by 심관혁 on 9/18/25.
//

import Core
import UI
import UIKit

// MARK: - UrgencyLevel UI 확장

extension UrgencyLevel {

    /// 긴급도에 따른 배경색
    public var backgroundColor: UIColor {
        switch self {
        case .critical:
            return UIColor.systemRed.withAlphaComponent(0.15)
        case .high:
            return UIColor.textRed.withAlphaComponent(0.1)
        case .medium:
            return UIColor.systemOrange.withAlphaComponent(0.1)
        case .low:
            return UIColor.systemYellow.withAlphaComponent(0.1)
        }
    }

    /// 긴급도에 따른 테두리 색상
    public var borderColor: UIColor {
        switch self {
        case .critical:
            return UIColor.systemRed.withAlphaComponent(0.5)
        case .high:
            return UIColor.textRed.withAlphaComponent(0.3)
        case .medium:
            return UIColor.systemOrange.withAlphaComponent(0.3)
        case .low:
            return UIColor.systemYellow.withAlphaComponent(0.3)
        }
    }

    /// 긴급도에 따른 시간 표시 색상
    public var timeColor: UIColor {
        switch self {
        case .critical:
            return UIColor.systemRed
        case .high:
            return UIColor.textRed
        case .medium:
            return UIColor.systemOrange
        case .low:
            return UIColor.systemYellow
        }
    }
}


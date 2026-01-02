//
//  ColorExtension.swift
//  AppManifests
//
//  Created by 예슬 on 8/18/25.
//

import UIKit

public let uiBundle = Bundle(
    identifier: "com.jipcoon.UI"
)  // 이미지 사용시 UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil)

public extension UIColor {
    /// Orange
    static let mainOrange = UIColor(
        named: "mainOrange",
        in: .module,
        compatibleWith: nil
    )!
    static let secondaryOrange = UIColor(
        named: "secondaryOrange",
        in: .module,
        compatibleWith: nil
    )!
    static let orange3 = UIColor(
        named: "orange3",
        in: .module,
        compatibleWith: nil
    )!

    /// Gray
    static let placeholderText = UIColor(
        named: "placeholderText",
        in: .module,
        compatibleWith: nil
    )!
    static let textFieldStroke = UIColor(
        named: "textFieldStroke",
        in: .module,
        compatibleWith: nil
    )!
    static let textGray = UIColor(
        named: "textGray",
        in: .module,
        compatibleWith: nil
    )!
    static let gray1 = UIColor(
        named: "gray1",
        in: .module,
        compatibleWith: nil
    )!

    /// Categories
    static let green1 = UIColor(
        named: "green1",
        in: .module,
        compatibleWith: nil
    )!
    static let blue1 = UIColor(
        named: "blue1",
        in: .module,
        compatibleWith: nil
    )!
    static let blue2 = UIColor(
        named: "blue2",
        in: .module,
        compatibleWith: nil
    )!
    static let purple1 = UIColor(
        named: "purple1",
        in: .module,
        compatibleWith: nil
    )!
    static let red1 = UIColor(named: "red1", in: .module, compatibleWith: nil)!
    static let yellow1 = UIColor(
        named: "yellow1",
        in: .module,
        compatibleWith: nil
    )!
    static let brown1 = UIColor(
        named: "brown1",
        in: .module,
        compatibleWith: nil
    )!

    // 나머지
    static let backgroundWhite = UIColor(
        named: "backgroundWhite",
        in: .module,
        compatibleWith: nil
    )!
    static let textRed = UIColor(
        named: "textRed",
        in: .module,
        compatibleWith: nil
    )!

    static let headerBeige = UIColor(
        named: "headerBeige",
        in: .module,
        compatibleWith: nil
    )!
    static let headerText = UIColor(
        named: "headerText",
        in: .module,
        compatibleWith: nil
    )!
    static let headerNotiBack = UIColor(
        named: "headerNotiBack",
        in: .module,
        compatibleWith: nil
    )!

    static func questCategoryColor(for colorName: String) -> UIColor {
        switch colorName {
        case "blue1": return .blue1
        case "blue2": return .blue2
        case "red1": return .red1
        case "yellow1": return .yellow1
        case "brown1": return .brown1
        case "orange3": return .orange3
        case "purple1": return .purple1
        case "green1": return .green1
        case "textFieldStroke": return .textFieldStroke
        default: return .systemGray

        }
    }
}

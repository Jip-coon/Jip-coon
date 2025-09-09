//
//  ColorExtension.swift
//  AppManifests
//
//  Created by 예슬 on 8/18/25.
//

import UIKit

public let uiBundle = Bundle(identifier: "com.jipcoon.UI")  // 이미지 사용시 UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil)

public extension UIColor {
    /// Orange
    static let mainOrange = UIColor(named: "mainOrange", in: .module, compatibleWith: nil)!
    static let secondaryOrange = UIColor(named: "secondaryOrange", in: .module, compatibleWith: nil)!
    static let orange3 = UIColor(named: "orange3", in: .module, compatibleWith: nil)!
    
    /// Gray
    static let placeholderText = UIColor(named: "placeholderText", in: .module, compatibleWith: nil)!
    static let textFieldStroke = UIColor(named: "textFieldStroke", in: .module, compatibleWith: nil)!
    static let textGray = UIColor(named: "textGray", in: .module, compatibleWith: nil)!
    
    static let backgroundWhite = UIColor(named: "backgroundWhite", in: .module, compatibleWith: nil)!
    static let textRed = UIColor(named: "textRed", in: .module, compatibleWith: nil)!
    static let green1 = UIColor(named: "green1", in: .module, compatibleWith: nil)!
    static let blue1 = UIColor(named: "blue1", in: .module, compatibleWith: nil)!
    static let purple1 = UIColor(named: "purple1", in: .module, compatibleWith: nil)!
}

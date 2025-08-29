//
//  ColorExtension.swift
//  AppManifests
//
//  Created by 예슬 on 8/18/25.
//

import UIKit

public let uiBundle = Bundle(identifier: "com.jipcoon.UI")  // 이미지 사용시 UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil)

public extension UIColor {
    static let mainOrange = UIColor(named: "mainOrange", in: .module, compatibleWith: nil)!
    static let secondaryOrange = UIColor(named: "secondaryOrange", in: .module, compatibleWith: nil)!
    static let backgroundWhite = UIColor(named: "backgroundWhite", in: .module, compatibleWith: nil)!
    static let placeholderText = UIColor(named: "placeholderText", in: .module, compatibleWith: nil)!
    static let textFieldStroke = UIColor(named: "textFieldStroke", in: .module, compatibleWith: nil)!
    static let textGray = UIColor(named: "textGray", in: .module, compatibleWith: nil)!
    static let textRed = UIColor(named: "textRed", in: .module, compatibleWith: nil)!
}

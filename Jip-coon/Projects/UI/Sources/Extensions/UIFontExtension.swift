//
//  UIFontExtension.swift
//  UI
//
//  Created by 예슬 on 9/5/25.
//

import UIKit
import CoreText

public extension UIFont {
    static func npsExtraBold(ofSize size: CGFloat) -> UIFont {
        FontRegistrar.registerIfNeeded()
        return UIFont(name: "NPS font ExtraBold", size: size)!
    }
}

// MARK: - 폰트 등록 유틸
private enum FontRegistrar {
    private static var didRegister = false

    static func registerIfNeeded() {
        guard !didRegister else { return }  // 한 번만 등록

        registerFont(named: "NPSfont_extrabold", ext: "ttf")
        didRegister = true
    }
    
    // 실제 번들에서 폰트 가져와 CoreText로 등록
    private static func registerFont(named: String, ext: String) {
        guard let url = Bundle.module.url(forResource: named, withExtension: ext),  // Tuist UI 모듈 번들에서 폰트 파일 경로 가져오기
              let provider = CGDataProvider(url: url as CFURL),
              let font = CGFont(provider) else {    // CoreText에서 폰트 객체 생성
            print("❌ Failed to load font: \(named).\(ext)")
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error) // 폰트를 시스템에 등록
        if let error = error {
            print("❌ Font registration error: \(error.takeUnretainedValue())")
        } else {
            print("✅ Font registered: \(font.fullName ?? "Unknown" as CFString)")
        }
    }
}

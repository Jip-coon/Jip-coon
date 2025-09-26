//
//  UIViewExtension.swift
//  UI
//
//  Created by 심관혁 on 9/18/25.
//

import UIKit

// MARK: - AutoLayout 편의 메서드

extension UIView {

    /// 여러 뷰들의 translatesAutoresizingMaskIntoConstraints를 false로 설정합니다
    /// - Parameter views: 설정할 뷰들의 배열
    public func disableAutoresizingMask(for views: UIView...) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    /// 현재 뷰와 하위 뷰들의 translatesAutoresizingMaskIntoConstraints를 false로 설정합니다
    /// - Parameter views: 추가로 설정할 뷰들
    public func disableAutoresizingMaskForAll(_ views: UIView...) {
        self.translatesAutoresizingMaskIntoConstraints = false
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    /// 뷰 배열의 translatesAutoresizingMaskIntoConstraints를 false로 설정합니다
    /// - Parameter views: 설정할 뷰들의 배열
    public static func disableAutoresizingMask(for views: [UIView]) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}

// MARK: - 그림자 및 모서리 편의 메서드

extension UIView {

    /// 표준 그림자 효과를 적용합니다
    public func applyShadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

    public func updateShadowPath(cornerRadius: CGFloat = 12) {
        if bounds != .zero {
            layer.shadowPath =
            UIBezierPath(
                roundedRect: bounds,
                cornerRadius: cornerRadius
            ).cgPath
        }
    }

    /// 표준 모서리 둥글기를 적용합니다
    public func applyCornerRadius(_ radius: CGFloat = 12) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }

    /// 카드 스타일 (그림자 + 모서리 둥글기)을 적용합니다
    public func applyCardStyle(
        cornerRadius: CGFloat = 12,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.1,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowRadius: CGFloat = 4
    ) {
        // 카드 스타일을 위한 모서리 둥글기 (그림자를 위해 clipsToBounds = false)
        layer.cornerRadius = cornerRadius
        clipsToBounds = false

        // 그림자 적용
        applyShadow(
            color: shadowColor, opacity: shadowOpacity, offset: shadowOffset, radius: shadowRadius)
    }
}

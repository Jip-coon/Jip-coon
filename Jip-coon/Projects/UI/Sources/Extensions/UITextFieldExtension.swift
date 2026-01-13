//
//  UITextFieldExtension.swift
//  UI
//
//  Created by 예슬 on 8/22/25.
//

import UIKit

public extension UITextField {
    func setPlaceholder(fontSize size: CGFloat = 16) {
        guard let string = self.placeholder else { return }
        
        attributedPlaceholder = NSAttributedString(
            string: string,
            attributes: [
                .foregroundColor: UIColor.placeholderText,
                .font: UIFont.pretendard(ofSize: size, weight: .regular)
            ]
        )
    }
    
    func leftPadding(of size: CGFloat = 16) {
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: size, height: self.frame.height)
        )
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}

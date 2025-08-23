//
//  UITextFieldExtension.swift
//  UI
//
//  Created by 예슬 on 8/22/25.
//

import UIKit

public extension UITextField {
    func setPlaceholder() {
        guard let string = self.placeholder else { return }
        
        attributedPlaceholder = NSAttributedString(
            string: string,
            attributes: [
                .foregroundColor: UIColor.placeholderText,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }
    
    func leftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}

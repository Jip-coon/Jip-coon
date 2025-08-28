//
//  SignUpViewModel.swift
//  Feature
//
//  Created by 예슬 on 8/28/25.
//

import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var email: String = "" {
        didSet { validateEmail() }
    }
    @Published var isEmailValid: Bool = true
    
    func validateEmail() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"    // (영문,숫자) + 골뱅이 + (영문,숫자) + . + 영문
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailValid = emailTest.evaluate(with: email)
    }
}

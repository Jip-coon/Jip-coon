//
//  SignUpViewModel.swift
//  Feature
//
//  Created by 예슬 on 8/28/25.
//

import Combine
import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var email: String = "" {
        didSet { validateEmail() }
    }
    @Published var password: String = "" {
        didSet { validatePassword() }
    }
    @Published var isEmailValid: Bool = true
    @Published var isPasswordValid: Bool = true
    @Published var isSignUpEnabled: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($isEmailValid, $isPasswordValid)
            .map { $0 && $1 }
            .assign(to: \.isSignUpEnabled, on: self)
            .store(in: &cancellables)
    }
    
    private func validateEmail() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"    // (영문,숫자) + 골뱅이 + (영문,숫자) + . + 영문
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailValid = emailTest.evaluate(with: email)
    }
    
    private func validatePassword() {
        isPasswordValid = password.count >= 6
    }
}

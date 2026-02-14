//
//  SignUpViewModel.swift
//  Feature
//
//  Created by 예슬 on 8/28/25.
//

import Combine
import Core
import Foundation

final class SignUpViewModel {
    @Published var email: String = "" {
        didSet { validateEmail() }
    }
    @Published var password: String = "" {
        didSet { validatePassword() }
    }
    @Published var isEmailFormatValid: Bool = true
    @Published var isEmailVerified: Bool = false
    @Published var isPasswordValid: Bool = true
    @Published var isSignUpEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let authService: AuthService
    private let userService: FirebaseUserService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authService: AuthService = AuthService(),
        userService: FirebaseUserService = FirebaseUserService()
    ) {
        self.authService = authService
        self.userService = userService
        
        Publishers.CombineLatest($isEmailFormatValid, $isPasswordValid)
            .map { $0 && $1 }
            .assign(to: \.isSignUpEnabled, on: self)
            .store(in: &cancellables)
    }
    
    private func validateEmail() {
        // (영문,숫자) + 골뱅이 + (영문,숫자) + . + 영문
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailFormatValid = emailTest.evaluate(with: email)
    }
    
    private func validatePassword() {
        isPasswordValid = password.count >= 6
    }
    
    func sendVerificationEmail(email: String) async -> Bool {
        let tempPassword = UUID().uuidString
        
        do {
            try await authService.signUp(email: email, password: tempPassword)
            
            guard let user = authService.currentUser else {
                throw NSError(domain: "AuthService", code: -1, userInfo: nil)
            }
            
            try await user.sendEmailVerification()
            try await userService.createTempUser(uid: user.uid, email: email)
            return true
        } catch {
            self.error = AuthError.map(from: error)
            return false
        }
    }
    
    func checkVerifiedEmail() async -> Bool {
        guard let user = authService.currentUser else { return false }
        
        do {
            try await user.reload()
            return user.isEmailVerified
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - 회원가입
    
    func performSignUp() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 현재 생성된 사용자의 UID 가져오기
            guard let currentUser = authService.currentUser else {
                throw NSError(
                    domain: "SignUp",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 가져올 수 없습니다."]
                )
            }
            
            try await authService.updatePassword(password)
            
            // 기본 사용자 정보 생성 (이름은 이메일의 앞부분으로 설정)
            let emailPrefix = email.components(separatedBy: "@").first ?? "사용자"
            let user = User(
                id: currentUser.uid,
                name: emailPrefix,
                email: email,
                role: .child
            )
            
            // Firestore에 사용자 정보 저장
            try await userService.createUser(user)
            try await userService.deleteTempUser(uid: currentUser.uid)
        } catch {
            self.error = AuthError.map(from: error)
            
            // 회원가입 실패 시 Firebase Auth 계정 삭제
            do {
                try await authService.deleteAccount()
            } catch {
                print("실패한 계정 정리 실패: \(error.localizedDescription)")
            }
        }
    }
}

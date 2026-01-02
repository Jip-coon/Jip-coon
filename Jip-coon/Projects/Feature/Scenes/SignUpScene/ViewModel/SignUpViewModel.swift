//
//  SignUpViewModel.swift
//  Feature
//
//  Created by 예슬 on 8/28/25.
//

import Combine
import Core
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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthService
    private let userService: FirebaseUserService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authService: AuthService = AuthService(),
        userService: FirebaseUserService = FirebaseUserService()
    ) {
        self.authService = authService
        self.userService = userService
        
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
    
    // MARK: - 회원가입
    
    func performSignUp() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Firebase Auth로 계정 생성
            try await authService.signUp(email: email, password: password)
            
            // 현재 생성된 사용자의 UID 가져오기
            guard let currentUser = authService.currentUser else {
                throw NSError(
                    domain: "SignUp",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 가져올 수 없습니다."]
                )
            }
            
            // 기본 사용자 정보 생성 (이름은 이메일의 앞부분으로 설정)
            // TODO: - 가족 역할 설정하기
            let emailPrefix = email.components(separatedBy: "@").first ?? "사용자"
            let user = User(
                id: currentUser.uid,
                name: emailPrefix,
                email: email,
                role: .child
            )
            
            // Firestore에 사용자 정보 저장
            try await userService.createUser(user)
            
            print("회원가입 및 Firestore 저장 성공")
        } catch {
            errorMessage = authService.handleError(error)
            
            // 회원가입 실패 시 Firebase Auth 계정 삭제
            do {
                try await authService.deleteAccount()
                print("실패한 계정 정리 완료")
            } catch {
                print("실패한 계정 정리 실패: \(error.localizedDescription)")
            }
        }
    }
}

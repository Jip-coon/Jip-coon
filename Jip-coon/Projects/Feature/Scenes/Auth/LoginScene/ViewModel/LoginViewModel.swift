//
//  LoginViewModel.swift
//  Feature
//
//  Created by 심관혁 on 8/27/25.
//

import Combine
import Core
import Foundation

public final class LoginViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public let loginSuccess = PassthroughSubject<Void, Never>()
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    public init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
    }
    
    @MainActor
    public func signIn() async {
        isLoading = true
        error = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            try await userService.syncCurrentUserDocument()
            loginSuccess.send()
        } catch {
            self.error = AuthError.map(from: error)
        }
        isLoading = false
    }
    
    /// 비밀번호 찾기(비밀번호 재설정 메일 전송)
    func sendPasswordResetEmail(email: String) async -> Bool {
        do {
            try await authService.sendPasswordResetEmail(email: email)
            return true
        } catch {
            self.error = AuthError.map(from: error)
            return false
        }
    }
    
}

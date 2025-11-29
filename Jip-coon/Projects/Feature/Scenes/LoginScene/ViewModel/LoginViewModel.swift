//
//  LoginViewModel.swift
//  Feature
//
//  Created by 심관혁 on 8/27/25.
//

import Foundation
import Combine
import Core

public final class LoginViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    public let loginSuccess = PassthroughSubject<Void, Never>()
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    public init(
        authService: AuthServiceProtocol = AuthService(),
        userService: UserServiceProtocol = FirebaseUserService()
    ) {
        self.authService = authService
        self.userService = userService
    }
    
    @MainActor
    public func signIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            try await userService.syncCurrentUserDocument()
            loginSuccess.send()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

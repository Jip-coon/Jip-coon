//
//  AppleLoginViewModel.swift
//  Feature
//
//  Created by 예슬 on 8/29/25.
//

import Combine
import Core
import Foundation

public final class AppleLoginViewModel {
    public let loginSuccess = PassthroughSubject<Void, Never>()
    public let loginFailure = PassthroughSubject<Error, Never>()
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    // MARK: - init
    
    public init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
    }
    
    // MARK: - Method
    
    @available(iOS 13, *)
    func login() {
        Task {
            do {
                try await authService.signInWithApple()
                try await userService.syncCurrentUserDocument()
                loginSuccess.send()
            } catch {
                loginFailure.send(error)
            }
        }
    }
}

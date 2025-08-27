//
//  AuthService.swift
//  Core
//
//  Created by 심관혁 on 8/27/25.
//

import Foundation
import FirebaseAuth

public final class AuthService: AuthServiceProtocol {
    public init() {}

    public func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    public func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    public func signOut() throws {
        try Auth.auth().signOut()
    }

    public var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}

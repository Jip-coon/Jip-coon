//
//  AuthServiceProtocol.swift
//  Core
//
//  Created by 심관혁 on 8/27/25.
//

import Foundation
import FirebaseAuth

public protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func deleteAccount() async throws
    func deleteAccountWithReauth(password: String) async throws
    func updatePassword(_ newPassword: String) async throws
    func sendPasswordResetEmail(email: String) async throws
    func handleError(_ error: Error) -> String

    var isLoggedIn: Bool { get }
    var currentUser: FirebaseAuth.User? { get }
    var currentUserEmail: String? { get }
}

//
//  AuthServiceProtocol.swift
//  Core
//
//  Created by 심관혁 on 8/27/25.
//

import Foundation

public protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func deleteAccount() throws
    var isLoggedIn: Bool { get }
    var currentUserEmail: String? { get }
}

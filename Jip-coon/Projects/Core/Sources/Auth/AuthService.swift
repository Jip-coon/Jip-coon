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

    public func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 정보가 존재하지 않습니다."])
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    public func deleteAccountWithReauth(password: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 정보가 존재하지 않습니다."])
        }

        // 현재 사용자의 이메일과 입력된 비밀번호로 credential 생성
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        // 재인증 수행
        try await user.reauthenticate(with: credential)

        // 재인증 성공 후 계정 삭제
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    public var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    public var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
}

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
    
    /// Firebase Auth 에러 처리
    public func handleError(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Firebase Auth 에러인지 확인
        guard nsError.domain == "FIRAuthErrorDomain" else {
            return error.localizedDescription
        }
        
        // AuthErrorCode로 변환
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }
        
        switch errorCode {
            case .emailAlreadyInUse:
                return "이미 가입된 이메일 계정입니다. \n로그인 또는 다른 이메일을 사용해주세요."
            case .invalidEmail:
                return "유효하지 않은 이메일 형식입니다."
            case .wrongPassword:
                return "비밀번호가 일치하지 않습니다."
            case .weakPassword:
                return "비밀번호가 너무 약합니다. 6자 이상 입력해주세요."
            case .userNotFound:
                return "사용자를 찾을 수 없습니다."
            default:
                return "알 수 없는 오류가 발생했습니다. 다시 시도해 주세요. (\(errorCode.rawValue))"
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

//
//  AuthService.swift
//  Core
//
//  Created by 심관혁 on 8/27/25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Foundation

public final class AuthService: AuthServiceProtocol {
    public init() {}
    
    /// 로그인
    public func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
        // 로그인 후 토큰 동기화
        syncFCMToken()
    }
    
    /// 회원가입
    public func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    /// 로그아웃
    public func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// 계정 삭제
    public func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인 정보가 존재하지 않습니다."]
            )
        }
        
        try await withCheckedThrowingContinuation { (
            continuation: CheckedContinuation<Void,
            Error>
        ) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    /// 회원탈퇴(재인증 성공 후 계정 삭제)
    public func deleteAccountWithReauth(password: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            throw NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인 정보가 존재하지 않습니다."]
            )
        }
        
        // 현재 사용자의 이메일과 입력된 비밀번호로 credential 생성
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )
        
        // 재인증 수행
        try await user.reauthenticate(with: credential)
        
        // 재인증 성공 후 계정 삭제
        try await withCheckedThrowingContinuation { (
            continuation: CheckedContinuation<Void,
            Error>
        ) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    /// 비밀번호 변경
    public func updatePassword(_ newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."]
            )
        }
        try await user.updatePassword(to: newPassword)
    }
    
    /// 비밀번호 재설정 메일 전송
    public func sendPasswordResetEmail(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// FCM 토큰 설정
    private func syncFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("FCM 토큰 가져오기 실패: \(error.localizedDescription)")
            } else if let token = token {
                // 로그인된 유저 ID 확인
                guard let userId = Auth.auth().currentUser?.uid else { return }
                
                // DB 업데이트
                let userRef = Firestore.firestore().collection("users").document(userId)
                userRef.updateData([
                    "fcmTokens": FieldValue.arrayUnion([token])
                ]) { error in
                    if let error = error {
                        print("토큰 DB 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("FCM 토큰 동기화 성공")
                    }
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
    
    // MARK: - Properties
    
    /// 로그인 여부 확인
    public var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// 현재 유저
    public var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}

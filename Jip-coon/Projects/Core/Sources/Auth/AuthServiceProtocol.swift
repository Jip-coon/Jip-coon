//
//  AuthServiceProtocol.swift
//  Core
//
//  Created by 심관혁 on 8/27/25.
//

import FirebaseAuth
import Foundation

public protocol AuthServiceProtocol {
    /// 로그인
    func signIn(email: String, password: String) async throws
    
    /// 회원가입
    func signUp(email: String, password: String) async throws
    
    /// 로그아웃
    func signOut() throws
    
    /// 계정 삭제
    func deleteAccount() async throws
    
    /// 회원탈퇴(재인증 성공 후 계정 삭제)
    func deleteAccountWithReauth(password: String?) async throws
    
    /// 비밀번호 변경
    func updatePassword(_ newPassword: String) async throws
    
    /// 비밀번호 재설정 메일 전송
    func sendPasswordResetEmail(email: String) async throws
    
    /// 로그인 여부 확인
    var isLoggedIn: Bool { get }
    
    /// 현재 유저
    var currentUser: FirebaseAuth.User? { get }
    
    // MARK: - 소셜 로그인
    
    /// 애플 로그인
    func signInWithApple() async throws
}

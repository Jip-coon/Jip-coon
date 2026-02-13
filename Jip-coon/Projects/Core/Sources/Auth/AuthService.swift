//
//  AuthService.swift
//  Core
//
//  Created by 심관혁 on 8/27/25.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import Foundation
import GoogleSignIn

public final class AuthService: NSObject, AuthServiceProtocol {
    public override init() {}
    
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
    public func deleteAccountWithReauth(password: String?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인 정보가 존재하지 않습니다."]
            )
        }
        
        let providerID = user.providerData.first?.providerID
        
        switch providerID {
            case "password":
                guard let password else {
                    throw AuthError.requiresPassword
                }
                try await reauthenticateWithPassword(password: password)
                
            case "apple.com":
                currentFlow = .reauthenticate
                try await reauthenticateWithApple()
                
            case "google.com":
                try await reauthenticateWithGoogle()
                
            default:
                throw AuthError.unsupportedProvider
                
        }
        
        // 재인증 성공 후 계정 삭제
        try await user.delete()
    }
    
    /// 이메일로 로그인시 재인증
    private func reauthenticateWithPassword(password: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            throw AuthError.notLoggedIn
        }
        
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )
        
        try await user.reauthenticate(with: credential)
    }
    
    /// 구글로 로그인시 재인증
    @MainActor
    func reauthenticateWithGoogle() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.notLoggedIn
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.invalidState
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController
        else {
            throw AuthError.invalidState
        }
        
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AuthError.invalidCredential
        }
        
        let accessToken = signInResult.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        try await user.reauthenticate(with: credential)
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
    
    // MARK: - Properties
    
    /// 로그인 여부 확인
    public var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// 현재 유저
    public var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    /// Apple Loing 관련
    private var currentNonce: String?
    private var continuation: CheckedContinuation<Void, Error>?
    private var currentFlow: AuthFlow?
}

// MARK: - Apple Login

extension AuthService {
    /// 로그인
    @available(iOS 13, *)
    public func signInWithApple() async throws {
        currentFlow = .login
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            self.continuation = continuation
            
            let nonce = randomNonceString()
            currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()  // Apple ID 제공자를 생성
            let request = appleIDProvider.createRequest()   // 인증 요청을 생성
            request.requestedScopes = [.fullName, .email]   // 사용자로부터 전체 이름과 이메일을 요청
            request.nonce = sha256(nonce)
            
            // 인증 요청을 처리할 컨트롤러를 생성
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self // 이 뷰 모델을 인증 컨트롤러의 delegate로 설정
            authorizationController.presentationContextProvider = self  // 이 뷰 모델을 인증 컨트롤러의 프레젠테이션 컨텍스트 제공자로 설정
            authorizationController.performRequests()   // 인증 요청을 수행
        }
    }
    
    /// 재인증
    @available(iOS 13, *)
    func reauthenticateWithApple() async throws {
        currentFlow = .reauthenticate
        
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            
            self.continuation = continuation
            
            let nonce = randomNonceString()
            currentNonce = nonce
            
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = []
            request.nonce = sha256(nonce)
            
            let controller = ASAuthorizationController(
                authorizationRequests: [request]
            )
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(
            kSecRandomDefault,
            randomBytes.count,
            &randomBytes
        )
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
}

extension AuthService: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                continuation?.resume(throwing: AuthError.invalidCredential)
                continuation = nil
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                continuation?.resume(throwing: AuthError.invalidCredential)
                continuation = nil
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                continuation?.resume(throwing: AuthError.invalidCredential)
                continuation = nil
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            switch currentFlow {
                case .login:
                    // Sign in with Firebase.
                    Auth.auth().signIn(with: credential) { (_, error) in
                        if let error {
                            // Error. If error.code == .MissingOrInvalidNonce, make sure
                            // you're sending the SHA256-hashed nonce as a hex string with
                            // your request to Apple.
                            self.continuation?.resume(throwing: error)
                            print(error.localizedDescription)
                        } else {
                            self.continuation?.resume()
                        }
                        
                        self.continuation = nil
                    }
                    
                case .reauthenticate:
                    guard let user = Auth.auth().currentUser else {
                        continuation?.resume(throwing: AuthError.notLoggedIn)
                        cleanup()
                        return
                    }
                    
                    user.reauthenticate(with: credential) { _, error in
                        if let error {
                            self.continuation?.resume(throwing: error)
                        } else {
                            self.continuation?.resume()
                        }
                        self.cleanup()
                    }
                    
                case .none:
                    continuation?.resume(throwing: AuthError.invalidState)
                    cleanup()
            }
        }
    }
    
    // 로그인 실패
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
        print("애플 로그인 실패", error.localizedDescription)
    }
    
    private func cleanup() {
        continuation = nil
        currentNonce = nil
        currentFlow = nil
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 현재 애플리케이션에서 활성화된 첫 번째 윈도우
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found")
        }
        return window
    }
}

// MARK: - AuthError

public enum AuthError: LocalizedError {
    case invalidCredential
    case notLoggedIn
    case invalidState
    case requiresPassword
    case unsupportedProvider
    // Firebase Error
    case emailAlreadyInUse
    case invalidEmail
    case wrongPassword
    case weakPassword
    case userNotFound
    case unknown(Int)
    
    public var errorDescription: String? {
        switch self {
            case .invalidCredential:
                return "인증 정보가 올바르지 않습니다."
            case .notLoggedIn:
                return "로그인이 필요합니다."
            case .invalidState:
                return "현재 인증 상태가 올바르지 않습니다."
            case .requiresPassword:
                return "비밀번호 재입력이 필요합니다."
            case .unsupportedProvider:
                return "지원하지 않는 로그인 방식입니다."
            case .emailAlreadyInUse:
                return "이미 가입된 이메일입니다."
            case .invalidEmail:
                return "유효하지 않은 이메일 형식입니다."
            case .wrongPassword:
                return "비밀번호가 일치하지 않습니다."
            case .weakPassword:
                return "비밀번호가 너무 약합니다."
            case .userNotFound:
                return "사용자를 찾을 수 없습니다."
            case .unknown:
                return "알 수 없는 오류가 발생했습니다."
        }
    }
}

extension AuthError {
    public static func map(from error: Error) -> AuthError {
        let nsError = error as NSError
        
        guard nsError.domain == AuthErrorDomain else {
            return .unknown(nsError.code)
        }
        
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(nsError.code)
        }
        
        switch code {
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .invalidEmail:
                return .invalidEmail
            case .wrongPassword:
                return .wrongPassword
            case .weakPassword:
                return .weakPassword
            case .userNotFound:
                return .userNotFound
            default:
                return .unknown(code.rawValue)
        }
    }
}

// MARK: - AuthFlow

private enum AuthFlow {
    case login
    case reauthenticate
}

//
//  GoogleLoginViewModel.swift
//  Feature
//
//  Created by 예슬 on 9/2/25.
//


import Combine
import Core
import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

public final class GoogleLoginViewModel {
    public let loginSuccess = PassthroughSubject<Void, Never>()
    private let userService: UserServiceProtocol
    
    public init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func signIn(presentingVC: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let _ = error {
                    return
                }
                if let _ = authResult?.user {
                    self.loginSuccess.send()
                    Task {
                        try await self.userService.syncCurrentUserDocument()
                    }
                }
            }
        }
    }
}

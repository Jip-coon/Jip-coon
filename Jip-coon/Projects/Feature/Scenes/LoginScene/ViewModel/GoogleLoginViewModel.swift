//
//  GoogleLoginViewModel.swift
//  Feature
//
//  Created by 예슬 on 9/2/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

final class GoogleLoginViewModel {
    public let loginSuccess = PassthroughSubject<Void, Never>()
    
    func signIn(presentingVC: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            guard error == nil else {
                // ...
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    return
                }
                if let user = authResult?.user {
                    self.loginSuccess.send()
                }
            }
        }
    }
}

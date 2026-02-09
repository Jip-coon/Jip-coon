//
//  AppDelegate.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/15/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import GoogleSignIn
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Messaging 및 UNUserNotificationCenter 대리자 설정
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // 푸시 알림 권한 요청
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        UINavigationBar.appearance().tintColor = .black
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        guard let token = fcmToken else { return }
        
        // 서버 DB에 토큰 저장 시도
        updateFCMTokenInFirestore(token: token)
    }
    
    /// Firestore의 users/{uid} 문서 내 fcmTokens 배열에 토큰을 추가
    private func updateFCMTokenInFirestore(token: String) {
        // 현재 로그인된 유저가 있는지 확인
        guard let userId = Auth.auth().currentUser?.uid else {
            print("로그인된 유저가 없어 토큰을 DB에 저장하지 않았습니다.")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        // 서버에서 User Token 업데이트
        userRef.updateData([
            "fcmTokens": FieldValue.arrayUnion([token])
        ]) { error in
            if let error = error {
                print("FCM 토큰 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("FCM 토큰이 성공적으로 Firestore에 저장되었습니다.")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// 앱이 포그라운드 상태일 때 알림이 오면 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 포그라운드에서도 소리, 배지, 배너가 뜨도록 설정
        completionHandler([.banner, .badge, .sound])
    }
}

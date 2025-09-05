//
//  SceneDelegate.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/15/25.
//

import UIKit
import Feature
import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: ws)
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
        self.window = window
        
        let loginViewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginViewController)

        // 로그인 상태 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let authService = AuthService()
            if authService.isLoggedIn {
                window.rootViewController = MainTabBarController()
            } else {
                window.rootViewController = navigationController
            }
        }
        
        // 로그인 성공 알림 구독
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginSuccess),
            name: NSNotification.Name("LoginSuccess"),
            object: nil
        )
        
        // 로그아웃 성공 알림 구독
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogoutSuccess),
            name: NSNotification.Name("LogoutSuccess"),
            object: nil
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    @objc private func handleLoginSuccess() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController = MainTabBarController()
            self?.window?.makeKeyAndVisible()
        }
    }
    
    @objc private func handleLogoutSuccess() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController = LoginViewController()
            self?.window?.makeKeyAndVisible()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

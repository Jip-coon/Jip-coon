//
//  SceneDelegate.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/15/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let viewController = UIViewController()
        viewController.view.backgroundColor = .orange

        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

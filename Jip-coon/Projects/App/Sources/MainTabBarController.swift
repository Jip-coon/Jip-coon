//
//  MainTabBarController.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/21/25.
//

import UIKit
import Feature

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        delegate = self

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupViewControllers() {
        // 해당 부분에 다른 뷰컨트롤러 추가
        // (VC(), 탭이름, 미선택 이미지, 선택 이미지)
		viewControllers = [
            (MainViewController(), "홈", "house", "house.fill"),
            (UIViewController(), "설정", "gear", "gear.fill"), // 임시 뷰
        ].enumerated().map { index, tab in
			createNavigationController(
                viewController: tab.0,
                title: tab.1,
                image: tab.2,
                selectedImage: tab.3,
                tag: index
            )
        }
    }

	private func createNavigationController(
        viewController: UIViewController,
        title: String,
        image: String,
        selectedImage: String,
        tag: Int
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )
        navigationController.tabBarItem.tag = tag
        return navigationController
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("선택된 탭: \(viewController.tabBarItem.tag)")
    }
}

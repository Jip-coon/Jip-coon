//
//  MainTabBarController.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/21/25.
//

import Core
import Feature
import UIKit

final class MainTabBarController: UITabBarController {
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol
    private let questService: QuestServiceProtocol

    init(userService: UserServiceProtocol, familyService: FamilyServiceProtocol, questService: QuestServiceProtocol) {
        self.userService = userService
        self.familyService = familyService
        self.questService = questService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let mainViewModel = MainViewModel(userService: userService, familyService: familyService, questService: questService)

        let navs: [UINavigationController] = [
            (MainViewController(viewModel: mainViewModel, userService: userService, familyService: familyService, questService: questService), "홈", "house", "house.fill"),
            (RankingViewController(userService: userService, familyService: familyService), "랭킹", "trophy", "trophy.fill"),
            (SettingViewController(), "설정", "gear", "gear.fill"),
        ]
            .enumerated()
            .map { (index: Int, tab: (UIViewController, String, String, String)) in
                createNavigationController(
                    viewController: tab.0,
                    title: tab.1,
                    image: tab.2,
                    selectedImage: tab.3,
                    tag: index
                )
            }
        self.viewControllers = navs
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

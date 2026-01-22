//
//  MainTabBarController.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/21/25.
//

import Core
import Feature
import UIKit

/// 앱의 주요 네비게이션 구조를 제공하는 탭바 컨트롤러
/// - 홈, 랭킹, 설정 탭으로 구성된 3탭 구조
/// - 각 탭에 해당하는 뷰 컨트롤러들을 네비게이션 컨트롤러로 래핑
/// - 서비스 의존성을 주입받아 각 화면에 필요한 데이터 서비스 제공
/// - UITabBarControllerDelegate를 통해 탭 선택 이벤트 처리
final class MainTabBarController: UITabBarController {
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol
    private let questService: QuestServiceProtocol

    /// 의존성 주입을 통한 탭바 컨트롤러 초기화
    /// - Parameters:
    ///   - userService: 사용자 데이터 관리를 위한 서비스
    ///   - familyService: 가족 데이터 관리를 위한 서비스
    ///   - questService: 퀘스트 데이터 관리를 위한 서비스
    /// - Note: 각 탭의 뷰 컨트롤러들이 동일한 서비스 인스턴스를 공유하도록
    ///         상위 레벨에서 서비스들을 주입받아 관리
    init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
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

    /// 탭바에 표시될 뷰 컨트롤러들을 설정하는 메소드
    /// - 각 탭별로 뷰 컨트롤러 생성 및 서비스 의존성 주입
    /// - 네비게이션 컨트롤러로 래핑하여 계층적 네비게이션 지원
    /// - 튜플 기반 설정으로 코드 가독성 향상
    private func setupViewControllers() {
        // 메인 화면용 뷰모델 생성 - 서비스들을 공유하여 데이터 일관성 확보
        let mainViewModel = MainViewModel(
            userService: userService,
            familyService: familyService,
            questService: questService
        )
        
        let allQuestViewModel = AllQuestViewModel(
            userService: userService,
            questService: questService
        )

        // 탭별 뷰 컨트롤러 설정: (컨트롤러, 탭 제목, 기본 아이콘, 선택 아이콘)
        let navs: [UINavigationController] = [
            // 홈
            (
                MainViewController(
                    viewModel: mainViewModel,
                    userService: userService,
                    familyService: familyService,
                    questService: questService
                ),
                "홈",
                "house",
                "house.fill"
            ),
            // 퀘스트
            (
                AllQuestViewController(viewModel: allQuestViewModel),
                "퀘스트",
                "list.star",
                "list.star"
            ),
            // 랭킹
            (
                RankingViewController(
                    userService: userService,
                    familyService: familyService
                ),
                "랭킹",
                "trophy",
                "trophy.fill"
            ),
            // 설정
            (
                SettingViewController(),
                "설정",
                "gear",
                "gear.fill"
            ),
        ]
            .enumerated()
            .map { (
                index: Int,
                tab: (UIViewController, String, String, String)
            ) in
                // 각 탭을 네비게이션 컨트롤러로 래핑하여 네비게이션 기능 제공
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

    /// 뷰 컨트롤러를 네비게이션 컨트롤러로 래핑하는 헬퍼 메소드
    /// - Parameters:
    ///   - viewController: 래핑할 루트 뷰 컨트롤러
    ///   - title: 탭바 아이템의 타이틀
    ///   - image: 선택되지 않은 상태의 SF Symbol 이미지 이름
    ///   - selectedImage: 선택된 상태의 SF Symbol 이미지 이름
    ///   - tag: 탭 식별을 위한 태그 값
    /// - Returns: 설정된 네비게이션 컨트롤러
    /// - Note: 재사용 가능한 네비게이션 컨트롤러 생성 로직을 분리하여 코드 중복 방지
    private func createNavigationController(
        viewController: UIViewController,
        title: String,
        image: String,
        selectedImage: String,
        tag: Int
    ) -> UINavigationController {
        // 네비게이션 컨트롤러 생성 및 루트 뷰 컨트롤러 설정
        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        // 탭바 아이템 설정: 타이틀과 SF Symbol 기반 아이콘
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )

        // 탭 식별을 위한 태그 설정 (디버깅 및 로깅 용도)
        navigationController.tabBarItem.tag = tag
        return navigationController
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        print("선택된 탭: \(viewController.tabBarItem.tag)")
    }
}

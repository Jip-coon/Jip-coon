//
//  MainTabBarController.swift
//  Jip-coon
//
//  Created by 심관혁 on 8/21/25.
//

import Core
import Feature
import UIKit

/// MainViewContoller를 메인 화면으로 설정
/// 기본 탭바 숨김
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
        setupMainViewController()
    }
    
    /// MainViewController를 메인 화면으로 설정
    private func setupMainViewController() {
        // 기본 탭바 숨김
        tabBar.isHidden = true
        
        // MainViewController를 자식으로 추가 (서비스 주입)
        let mainVC = MainViewController(
            userService: userService,
            familyService: familyService,
            questService: questService
        )
        addChild(mainVC)
        view.addSubview(mainVC.view)
        mainVC.view.frame = view.bounds
        mainVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainVC.didMove(toParent: self)
    }
}

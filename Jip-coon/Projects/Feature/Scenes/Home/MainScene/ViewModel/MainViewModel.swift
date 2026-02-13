//
//  MainViewModel.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import Combine
import Core
import Foundation

/// 메인 화면의 ViewModel
final class MainViewModel {
    
    // MARK: - Services
    
    private let userService: UserServiceProtocol?
    private let familyService: FamilyServiceProtocol?
    private let questService: QuestServiceProtocol?
    
    // MARK: - Published Properties
    
    /// 현재 선택된 탭 인덱스
    @Published var selectedTabIndex: Int = 0
    
    // MARK: - Initialization
    
    init(
        userService: UserServiceProtocol? = nil,
        familyService: FamilyServiceProtocol? = nil,
        questService: QuestServiceProtocol? = nil
    ) {
        self.userService = userService
        self.familyService = familyService
        self.questService = questService
    }
    
    // MARK: - Public Methods
    
    /// 탭 선택 변경
    func selectTab(at index: Int) {
        selectedTabIndex = index
    }
    
    /// UserService 반환
    func getUserService() -> UserServiceProtocol? {
        return userService
    }
    
    /// FamilyService 반환
    func getFamilyService() -> FamilyServiceProtocol? {
        return familyService
    }
    
    /// QuestService 반환
    func getQuestService() -> QuestServiceProtocol? {
        return questService
    }
    
    /// 타임존 업데이트
    func updateTimeZone() async {
        let currentTimeZone = TimeZone.current.identifier
        let savedTimeZone = UserDefaults.standard.string(forKey: "lastTimeZone")
        
        if savedTimeZone == nil || currentTimeZone != savedTimeZone {
            guard let userService,
                  let user = try? await userService.getCurrentUser()
            else {
                print("현재 로그인된 사용자가 없습니다.")
                return
            }
            
            await userService.updateUserTimeZone(userId: user.id)
            UserDefaults.standard.set(currentTimeZone, forKey: "lastTimeZone")
        }
    }
}

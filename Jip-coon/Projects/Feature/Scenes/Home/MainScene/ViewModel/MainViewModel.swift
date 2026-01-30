//
//  MainViewModel.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import Foundation
import Core
import Combine

/// 메인 화면의 ViewModel
public class MainViewModel {
    
    // MARK: - Services
    
    private let userService: UserServiceProtocol?
    private let familyService: FamilyServiceProtocol?
    private let questService: QuestServiceProtocol?
    
    // MARK: - Published Properties
    
    /// 현재 선택된 탭 인덱스
    @Published var selectedTabIndex: Int = 0
    
    // MARK: - Initialization
    
    public init(
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
}

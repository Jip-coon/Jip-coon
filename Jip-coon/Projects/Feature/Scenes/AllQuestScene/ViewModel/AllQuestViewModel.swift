//
//  AllQuestViewModel.swift
//  Feature
//
//  Created by 예슬 on 1/19/26.
//

import Core
import Foundation

final class AllQuestViewModel: ObservableObject {
    
    private let userService: UserServiceProtocol
    private let questService: QuestServiceProtocol
    
    init(
        userService: UserServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.userService = userService
        self.questService = questService
    }
    
    
}

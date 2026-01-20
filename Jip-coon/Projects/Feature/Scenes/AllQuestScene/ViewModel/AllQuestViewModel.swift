//
//  AllQuestViewModel.swift
//  Feature
//
//  Created by 예슬 on 1/19/26.
//

import Core
import Foundation

public final class AllQuestViewModel: ObservableObject {
    
    private let userService: UserServiceProtocol
    private let questService: QuestServiceProtocol
    
    public init(
        userService: UserServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.userService = userService
        self.questService = questService
        
        Task {
            await fetchFamilyMembers()
            await fetchAllQuests()
        }
    }
    
    // MARK: - Properties
    
    @Published var allQuests: [Quest] = []
    @Published var filteredQuests: [Quest] = []
    
    var familyMembers: [User] = []
    
    // MARK: - Method
    
    private func fetchFamilyMembers() async {
        do {
            guard let user = try await userService.getCurrentUser() else {
                print("현재 사용자 정보를 가져오지 못했습니다.")
                return
            }
            
            guard let familyId = user.familyId else {
                print("가족 ID가 없습니다.")
                return
            }
            
            familyMembers = try await userService.getFamilyMembers(familyId: familyId)
        } catch {
            print("가족 구성원을 불러오지 못했습니다.")
        }
    }
    
    
    /// 현재 가족의 모든 퀘스트를 조회
    private func fetchAllQuests() async {
        do {
            guard let user = try await userService.getCurrentUser() else {
                print("현재 사용자 정보를 가져오지 못했습니다.")
                return
            }
            
            guard let familyId = user.familyId else {
                print("가족 ID가 없습니다.")
                return
            }
            
            allQuests = try await questService.getFamilyQuests(familyId: familyId)
        } catch {
            print("퀘스트를 불러오지 못했습니다.")
        }
    }
    
    
}

//
//  AddMissionViewModel.swift
//  Feature
//
//  Created by 예슬 on 9/12/25.
//

import Foundation
import Combine
import Core

final class AddMissionViewModel: ObservableObject {
    @Published var familyMembers: [User] = []
    @Published var selectedWorkerName: String = "선택해 주세요"
    @Published private(set) var recurringType: RecurringType = .none
    @Published var selectedRepeatDays: Set<Day> = []
    
    // TODO: - Firebase에서 데이터 가져오기
    func fetchFamilyMembers(for currentFamilyId: String) {
        // Sample data
        let user1 = User(id: "user123", name: "예슬", email: "yeseul@example.com", role: .parent)
        let user2 = User(id: "user456", name: "관혁", email: "jipcoon@example.com", role: .child)
        
        self.familyMembers = [user1, user2]
    }
    
    // 담당자 저장
    func selectWorker(with name: String) {
        self.selectedWorkerName = name
    }
    
    // 요일 반복 저장
    func updateSelectedRepeatDays(_ days: [Day]) {
        self.selectedRepeatDays = Set(days)
        
        if days.isEmpty {
            recurringType = .none
        } else if days.count == 7 {
            recurringType = .daily
        } else {
            recurringType = .weekly
        }
    }
    
}

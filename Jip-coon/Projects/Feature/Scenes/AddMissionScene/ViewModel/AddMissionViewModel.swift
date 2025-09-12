//
//  AddMissionViewModel.swift
//  Feature
//
//  Created by 예슬 on 9/12/25.
//

import Foundation
import Combine
import Core

final class AddMissionViewModel {
    @Published var familyMembers: [User] = []
    @Published var selectedWorkerName: String = "선택해 주세요"
    
    // TODO: - Firebase에서 데이터 가져오기
    func fetchFamilyMembers(for currentFamilyId: String) {
        // Sample data
        let family = Family(id: currentFamilyId, name: "우리 가족", createdBy: "user123")
        let user1 = User(id: "user123", name: "예슬", email: "yeseul@example.com", role: .parent)
        let user2 = User(id: "user456", name: "관혁", email: "jipcoon@example.com", role: .child)
        
        self.familyMembers = [user1, user2]
    }
    
    // UIMenu에서 이름을 선택했을 때 호출되는 메서드
    func selectWorker(with name: String) {
        self.selectedWorkerName = name
    }
}

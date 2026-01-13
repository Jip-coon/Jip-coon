//
//  AddQuestViewModel.swift
//  Feature
//
//  Created by 예슬 on 9/12/25.
//

import Foundation
import Combine
import Core

final class AddQuestViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol
    private let questService: QuestServiceProtocol

    init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.userService = userService
        self.familyService = familyService
        self.questService = questService
    }
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var questCreateDate: Date = Date()
    @Published var selectedDate: Date = Date()  // 선택된 날짜
    @Published var selectedTime: Date = Date()  // 선택된 시간
    @Published var questDueDate: Date? // 최종 마감 시간 (선택된 날짜 + 시간)
    @Published var category: QuestCategory = .laundry
    @Published var familyMembers: [User] = []   // 가족 구성원
    @Published var selectedWorkerName: String = "선택해 주세요"   // 선택된 담당자
    @Published var starCount: Int = 10
    @Published private(set) var recurringType: RecurringType = .none    // 반복 타입
    @Published var selectedRepeatDays: Set<Day> = []    // 선택된 반복 요일
    
    // TODO: - Firebase에서 데이터 가져오기
    func fetchFamilyMembers(for currentFamilyId: String) {
        // Sample data
        let user1 = User(
            id: "user123",
            name: "예슬",
            email: "yeseul@example.com",
            role: .parent
        )
        let user2 = User(
            id: "user456",
            name: "관혁",
            email: "jipcoon@example.com",
            role: .child
        )
        
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
    
    func combineDateAndTime() {
        let calendar = Calendar.current
        
        // 날짜와 시간 각각의 컴포넌트 추출
        let dateComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: selectedDate
        )
        let timeComponents = calendar.dateComponents(
            [.hour, .minute],
            from: selectedTime
        )
        
        // 합치기
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = 0
        
        // 최종 missionDueDate 생성
        questDueDate = calendar.date(from: mergedComponents)
    }
    
    // 퀘스트 데이터 저장
    func saveMission() async throws {
        // 현재 사용자 정보 가져오기
        guard let currentUser = try await userService.getCurrentUser() else {
            throw AddQuestError.userNotFound
        }

        // 가족 ID 가져오기 (없으면 더미 가족 ID 사용)
        let familyId = currentUser.familyId ?? "dummy_family_id"

        // 선택된 담당자 ID 찾기
        var assignedTo: String? = familyMembers.first(
            where: { $0.name == selectedWorkerName
            })?.id

        // "선택해 주세요"인 경우 현재 사용자를 담당자로 설정
        if selectedWorkerName == "선택해 주세요" || assignedTo == nil {
            assignedTo = currentUser.id
        }

        // Quest 객체 생성
        let quest = Quest(
            title: title,
            description: description.isEmpty ? nil : description,
            category: category,
            createdBy: currentUser.id,
            familyId: familyId,
            points: starCount
        )

        // 마감일 설정
        var questToSave = quest
        questToSave.dueDate = questDueDate
        questToSave.recurringType = recurringType
        questToSave.assignedTo = assignedTo

        // Firebase에 저장
        _ = try await questService.createQuest(questToSave)
    }

}

// MARK: - Error Types

enum AddQuestError: LocalizedError {
    case userNotFound
    case familyNotFound
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "사용자 정보를 찾을 수 없습니다"
        case .familyNotFound:
            return "가족 정보를 찾을 수 없습니다"
        case .saveFailed(let details):
            return "퀘스트 저장에 실패했습니다: \(details)"
        }
    }
}

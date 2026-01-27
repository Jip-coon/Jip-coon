//
//  QuestDetailViewModel.swift
//  Feature
//
//  Created by 예슬 on 11/19/25.
//

import Core
import Combine
import Foundation

final class QuestDetailViewModel: ObservableObject {
    @Published var quest: Quest

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var questCreateDate: Date = Date()
    @Published var selectedDate: Date = Date()  // 선택된 날짜
    @Published var selectedTime: Date = Date()  // 선택된 시간
    @Published var category: QuestCategory = .laundry
    @Published var familyMembers: [User] = []   // 가족 구성원
    @Published var selectedWorkerName: String = "선택해 주세요"   // 선택된 담당자
    @Published var starCount: Int = 10
    @Published private(set) var recurringType: RecurringType = .none    // 반복 타입
    @Published var selectedRepeatDays: Set<Day> = []    // 선택된 반복 요일

    private let questService: QuestServiceProtocol
    private let userService: UserServiceProtocol

    init(
        quest: Quest,
        questService: QuestServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.quest = quest
        self.questService = questService
        self.userService = userService
        loadQuestData()
    }
    
    func loadQuestData() {
        title = quest.title
        description = quest.description ?? ""
        category = quest.category
        starCount = quest.points
        recurringType = quest.recurringType
        
        if let due = quest.dueDate {
            selectedDate = due
            selectedTime = due
        }
        
        // 가족 구성원 정보를 로드한 후 담당자 이름 설정
        fetchFamilyMembers()
    }
    
    // MARK: - Data Updates
    
    func updateTitle(_ newTitle: String) {
        title = newTitle
    }
    
    func updateDescription(_ newDescription: String) {
        description = newDescription
    }
    
    func updateDate(_ newDate: Date) {
        selectedDate = newDate
    }
    
    func updateTime(_ newTime: Date) {
        selectedTime = newTime
    }
    
    func updateWorker(_ workerName: String) {
        selectedWorkerName = workerName
    }
    
    func updateStarCount(_ count: Int) {
        starCount = count
    }
    
    func updateCategory(_ newCategory: QuestCategory) {
        category = newCategory
    }
    
    func saveChanges() {
        quest.title = title
        quest.description = description
        quest.category = category
        
        // 담당자 이름을 ID로 변환하여 저장
        if let member = familyMembers.first(where: { $0.name == selectedWorkerName }) {
            quest.assignedTo = member.id
        } else {
            quest.assignedTo = selectedWorkerName
        }
        
        quest.points = starCount
        quest.dueDate = combineDateAndTime()
        quest.recurringType = recurringType
    }
    
    func combineDateAndTime() -> Date {
        let calendar = Calendar.current
        let day = calendar.dateComponents(
            [.year, .month, .day],
            from: selectedDate
        )
        let time = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var merged = DateComponents()
        merged.year = day.year
        merged.month = day.month
        merged.day = day.day
        merged.hour = time.hour
        merged.minute = time.minute
        
        return calendar.date(from: merged) ?? Date()
    }
    
    func fetchFamilyMembers() {
        Task {
            do {
                // 현재 사용자 정보 가져오기
                let currentUser = try await userService.getCurrentUser()
                guard let familyId = currentUser?.familyId else {
                    await MainActor.run {
                        self.selectedWorkerName = quest.assignedTo ?? "선택해 주세요"
                    }
                    return
                }
                
                // 가족 구성원 정보 가져오기
                let members = try await userService.getFamilyMembers(familyId: familyId)
                
                await MainActor.run {
                    self.familyMembers = members
                    
                    // 담당자 ID를 이름으로 변환
                    if let assignedToId = quest.assignedTo {
                        if let member = members.first(where: { $0.id == assignedToId }) {
                            self.selectedWorkerName = member.name
                        } else {
                            self.selectedWorkerName = assignedToId
                        }
                    } else {
                        self.selectedWorkerName = "선택해 주세요"
                    }
                }
            } catch {
                print("가족 구성원 로드 실패: \(error.localizedDescription)")
                await MainActor.run {
                    self.selectedWorkerName = quest.assignedTo ?? "선택해 주세요"
                }
            }
        }
    }

    // 퀘스트 완료 처리
    func completeQuest() async throws {
        // 현재 사용자 정보 가져오기
        guard let currentUser = try await userService.getCurrentUser() else {
            throw QuestDetailError.userNotFound
        }

        // 담당자가 지정되지 않은 퀘스트이거나, 담당자가 현재 사용자인 경우에만 완료 가능
        guard quest.assignedTo == nil || quest.assignedTo == currentUser.id else {
            throw QuestDetailError.notAssignedToQuest
        }

        // 퀘스트 상태를 completed로 변경
        try await questService
            .updateQuestStatus(quest: quest, status: .completed)

        // 담당자가 지정되지 않은 퀘스트였다면, 완료 시점에 담당자를 현재 사용자로 설정
        var questToUpdate = quest
        if quest.assignedTo == nil {
            questToUpdate.assignedTo = currentUser.id
            // Firestore에도 담당자 정보 업데이트
            try await questService.updateQuest(questToUpdate)
        }

        // 포인트 부여: 퀘스트의 포인트만큼 사용자에게 추가
        let newPoints = currentUser.points + quest.points
        try await userService
            .updateUserPoints(userId: currentUser.id, points: newPoints)

        // 로컬 quest 객체도 업데이트
        var updatedQuest = questToUpdate
        updatedQuest.status = .completed
        updatedQuest.completedAt = Date()
        updatedQuest.updatedAt = Date()
        self.quest = updatedQuest
    }
}

// MARK: - Error Types
enum QuestDetailError: LocalizedError {
    case notAssignedToQuest
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .notAssignedToQuest:
            return "이 퀘스트의 담당자가 아닙니다"
        case .userNotFound:
            return "사용자 정보를 찾을 수 없습니다"
        }
    }
}

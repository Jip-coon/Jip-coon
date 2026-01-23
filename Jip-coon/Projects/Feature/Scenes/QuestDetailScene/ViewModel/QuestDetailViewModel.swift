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
    @Published var selectedDate: Date = Date()  // 선택된 날짜
    @Published var selectedTime: Date = Date()  // 선택된 시간
    @Published var category: QuestCategory = .laundry
    @Published var selectedWorkerName: String = "선택해 주세요"   // 선택된 담당자
    @Published var starCount: Int = 10
    @Published var selectedRepeatDays: Set<Day> = []    // 선택된 반복 요일
    
    var title: String = ""
    var familyMembers: [User] = []   // 가족 구성원
    var recurringEndDate: Date?
    private(set) var recurringType: RecurringType = .none    // 반복 타입
    private var description: String = ""
    
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
        selectedWorkerName = quest.assignedTo ?? ""
        starCount = quest.points
        recurringType = quest.recurringType
        
        if let due = quest.dueDate {
            selectedDate = due
            selectedTime = due
        }
        
        // 반복 요일 설정
        if let days = quest.selectedRepeatDays {
            self.selectedRepeatDays = Set(days.compactMap { index in
                // index가 0(일)~6(토)일 경우를 대비한 매핑
                Day.allCases.first { $0.weekdayIndex == index }
            })
        }
        
        self.recurringEndDate = quest.recurringEndDate
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
    
    func saveChanges() async throws {
        quest.title = title
        quest.description = description
        quest.category = category
        quest.assignedTo = selectedWorkerName
        quest.points = starCount
        quest.dueDate = combineDateAndTime()
        quest.recurringType = recurringType
        quest.recurringEndDate = recurringEndDate
        quest.selectedRepeatDays = selectedRepeatDays.map { $0.weekdayIndex }
        
        do {
            try await questService.updateQuest(quest)
        } catch {
            throw QuestDetailError.questUpdateFail
        }
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
        // TODO: - 가족이름 불러오기
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
    case questUpdateFail

    var errorDescription: String? {
        switch self {
            case .notAssignedToQuest:
                return "이 퀘스트의 담당자가 아닙니다"
            case .userNotFound:
                return "사용자 정보를 찾을 수 없습니다"
            case .questUpdateFail:
                return "퀘스트 수정에 실패했습니다"
        }
    }
}

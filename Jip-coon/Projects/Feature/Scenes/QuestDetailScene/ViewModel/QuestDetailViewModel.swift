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
    
    init(quest: Quest) {
        self.quest = quest
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
        quest.assignedTo = selectedWorkerName
        quest.points = starCount
        quest.dueDate = combineDateAndTime()
        quest.recurringType = recurringType
    }
    
    func combineDateAndTime() -> Date {
        let calendar = Calendar.current
        let day = calendar.dateComponents([.year, .month, .day], from: selectedDate)
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
}

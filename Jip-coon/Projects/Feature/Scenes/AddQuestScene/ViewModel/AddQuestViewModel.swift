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
    @Published var missionTitle: String = ""
    @Published var missionDescription: String = ""
    @Published var missionCreateDate: Date = Date()
    @Published var selectedDate: Date = Date()  // 선택된 날짜
    @Published var selectedTime: Date = Date()  // 선택된 시간
    @Published var missionDueDate: Date? // 최종 마감 시간 (선택된 날짜 + 시간)
    @Published var missionCategory: QuestCategory = .laundry
    @Published var familyMembers: [User] = []   // 가족 구성원
    @Published var selectedWorkerName: String = "선택해 주세요"   // 선택된 담당자
    @Published var starCount: Int = 10
    @Published private(set) var recurringType: RecurringType = .none    // 반복 타입
    @Published var selectedRepeatDays: Set<Day> = []    // 선택된 반복 요일
    
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
    
    func combineDateAndTime() {
        let calendar = Calendar.current
        
        // 날짜와 시간 각각의 컴포넌트 추출
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        // 합치기
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = 0
        
        // 최종 missionDueDate 생성
        missionDueDate = calendar.date(from: mergedComponents)
    }
    
    // TODO: - 퀘스트 데이터 저장
    func saveMission() {
        print("Save Mission:")
        print("Title:", missionTitle)
        print("Description:", missionDescription)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = .current
        
        print("MissionDueDate (local):", formatter.string(from: missionDueDate ?? Date()))
        print("Date:", formatter.string(from: selectedDate))
        print("Time:", formatter.string(from: selectedTime))
        
        print("Worker:", selectedWorkerName)
        print("Star:", starCount)
        print("Recurring:", recurringType)
        print("Repeat Days:", selectedRepeatDays)
        print("Category:", missionCategory)
    }
    
}

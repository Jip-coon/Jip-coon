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
        // 초기 데이터 세팅
        changeSelectedSegment()
    }
    
    enum AllQuestSegmentControl {
        case today
        case upcoming
        case past
    }
    
    // MARK: - Properties
    
    @Published var allQuests: [Quest] = [] {
        didSet { filterQuests() }
    }
    @Published var selectedSegment: AllQuestSegmentControl = .today {
        didSet { changeSelectedSegment() }
    }
    @Published private(set) var currentQuests: [Quest] = []
    
    var familyMembers: [User] = []
    var todayQuests: [Quest] = []
    var upcomingQuests: [Quest] = []
    var pastQuests: [Quest] = []
    
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
    func fetchAllQuests() async {
        do {
            guard let user = try await userService.getCurrentUser() else {
                print("현재 사용자 정보를 가져오지 못했습니다.")
                return
            }
            
            guard let familyId = user.familyId else {
                print("가족 ID가 없습니다.")
                return
            }
            
            let quests = try await questService.getFamilyQuests(familyId: familyId)
            await MainActor.run { self.allQuests = quests }
        } catch {
            print("퀘스트를 불러오지 못했습니다.")
        }
    }
    
    /// 모든 퀘스트를 기준으로 퀘스트 분리
    /// - 오늘 퀘스트
    /// - 예정 퀘스트(내일 - 7일 후)
    /// - 과거 퀘스트(7일 전 - 어제)
    private func filterQuests() {
        filterTodayQuests()
        filterUpcomingQuests()
        filterPastQuests()
        changeSelectedSegment()
    }
    
    private func changeSelectedSegment() {
        switch selectedSegment {
            case .today:
                currentQuests = todayQuests
            case .upcoming:
                currentQuests = upcomingQuests
            case .past:
                currentQuests = pastQuests
        }
    }
    
    /// 오늘 퀘스트
    private func filterTodayQuests() {
        var cal = Calendar.current
        cal.timeZone = .current
        let today = Date()
        
        todayQuests = allQuests
            .filter { quest in
                guard let due = quest.dueDate else { return false }
                return cal.isDate(due, inSameDayAs: today)
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }
    
    /// 예정 퀘스트(내일 - 7일 후)
    private func filterUpcomingQuests() {
        var cal = Calendar.current
        cal.timeZone = .current
        let todayStart = cal.startOfDay(for: Date())
        let tomorrow = cal.date(byAdding: .day, value: 1, to: todayStart)!
        let sevenDaysLater = cal.date(byAdding: .day, value: 7, to: todayStart)!
        
        upcomingQuests = allQuests
            .filter { quest in
                guard let due = quest.dueDate else { return false }
                return due >= tomorrow && due <= sevenDaysLater
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }
    
    /// 과거 퀘스트(7일 전 - 어제)
    private func filterPastQuests() {
        var cal = Calendar.current
        cal.timeZone = .current
        let todayStart = cal.startOfDay(for: Date())
        let sevenDaysAgo = cal.date(byAdding: .day, value: -7, to: todayStart)!
        
        pastQuests = allQuests
            .filter { quest in
                guard let due = quest.dueDate else { return false }
                return due < todayStart && due >= sevenDaysAgo
            }
        // 가장 최근이 위 (내림차순)
            .sorted { ($0.dueDate ?? .distantPast) > ($1.dueDate ?? .distantPast) }
    }
}

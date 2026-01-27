//
//  AllQuestViewModel.swift
//  Feature
//
//  Created by 예슬 on 1/19/26.
//

import Core
import Foundation

public final class AllQuestViewModel: ObservableObject {
    
    let userService: UserServiceProtocol
    let questService: QuestServiceProtocol
    
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
        updateCurrentQuests()
    }
    
    enum AllQuestSegmentControl {
        case today
        case upcoming
        case past
    }
    
    // MARK: - Properties
    
    @Published private(set) var sectionedQuests: [QuestSection] = []
    
    var selectedSegment: AllQuestSegmentControl = .today {
        didSet { updateCurrentQuests() }
    }
    var selectedStatusOptions: Set<FilterButtonView.FilterOption> = [.all] {
        didSet { updateCurrentQuests() }
    }
    
    private(set) var familyMembers: [User] = []
    private var todayQuests: [Quest] = []
    private var upcomingQuests: [Quest] = []
    private var pastQuests: [Quest] = []
    private var allQuests: [Quest] = [] {
        didSet { filterQuestsByDate() }
    }
    
    // MARK: - 서버에서 데이터 가져오기
    
    /// 가족 정보 가져오기
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
        guard let user = try? await userService.getCurrentUser() else {
            print("현재 사용자 정보를 가져오지 못했습니다.")
            return
        }
        
        guard let familyId = user.familyId else {
            print("가족 ID가 없습니다.")
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 탭 구성을 위해 오늘 기준 ±7일 범위를 설정
        let startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        let endDate = calendar.date(byAdding: .day, value: 7, to: today)!
        
        do {
            let quests = try await questService.fetchQuestsWithRepeat(
                familyId: familyId,
                startDate: startDate,
                endDate: endDate
            )
            await MainActor.run { self.allQuests = quests }
        } catch {
            print("퀘스트를 불러오지 못했습니다.")
        }
    }
    
    // MARK: - 필터링 관리
    
    /// 모든 퀘스트를 기준으로 퀘스트 분리
    /// - 오늘 퀘스트
    /// - 예정 퀘스트(내일 - 7일 후)
    /// - 과거 퀘스트(7일 전 - 어제)
    private func filterQuestsByDate() {
        filterTodayQuests()
        filterUpcomingQuests()
        filterPastQuests()
        updateCurrentQuests()
    }
    
    /// 필터(날짜, 상태) 적용된 데이터 가져오기
    /// - 현재 탭(날짜별)에 맞는 데이터셋 확보
    /// - 확보된 데이터셋에 상태 필터 적용
    /// - 최종 결과물 업데이트
    private func updateCurrentQuests() {
        let dateFiltered = getQuestsForCurrentSegment()
        let statusFiltered = applyStatusFilter(to: dateFiltered)
        
        // 섹션 나누기
        if selectedSegment == .today {
            self.sectionedQuests = statusFiltered.isEmpty ? [] : [QuestSection(date: Date(), quests: statusFiltered)]
        } else {
            self.sectionedQuests = groupQuestsByDate(statusFiltered)
        }
    }
    
    // MARK: - Helper (날짜별)
    
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
    
    // MARK: - Helper (상태별)
    
    /// 날짜 탭에 따른 데이터 선택
    private func getQuestsForCurrentSegment() -> [Quest] {
        switch selectedSegment {
            case .today: return todayQuests
            case .upcoming: return upcomingQuests
            case .past: return pastQuests
        }
    }
    
    /// 상태 옵션에 따른 데이터 필터링
    private func applyStatusFilter(to quests: [Quest]) -> [Quest] {
        // '전체'가 포함되어 있으면 필터링 없이 그대로 반환
        if selectedStatusOptions.contains(.all) {
            return quests
        }
        
        // 선택된 상태값만 추출
        return quests.filter { quest in
            selectedStatusOptions.contains { option in
                isMatch(quest: quest, with: option)
            }
        }
    }
    
    /// 개별 옵션 매칭 로직
    private func isMatch(quest: Quest, with option: FilterButtonView.FilterOption) -> Bool {
        switch option {
            case .pending:
                return quest.status == .pending
            case .progressing:
                return quest.status == .inProgress
            case .completed:
                return [.completed, .approved, .rejected].contains(quest.status)
            default:
                return false
        }
    }
    
    // MARK: - Helper (섹션)
    
    /// 날짜별 그룹화
    private func groupQuestsByDate(_ quests: [Quest]) -> [QuestSection] {
        let dictionary = Dictionary(grouping: quests) { (quest) -> Date in
            // 시간을 제외한 "날짜" 정보만 추출하여 키값으로 사용
            return Calendar.current.startOfDay(for: quest.dueDate ?? Date())
        }
        
        // 날짜순으로 정렬하여 Section 배열 생성
        return dictionary.keys.sorted(by: {
            selectedSegment == .upcoming ? $0 < $1 : $0 > $1
        }).map {
            QuestSection(date: $0, quests: dictionary[$0] ?? [])
        }
    }
    
}

// MARK: - Quest Section

struct QuestSection {
    let date: Date
    let quests: [Quest]
}

//
//  MainViewModel.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import Combine
import Core
import Foundation
import UI

@MainActor
public class MainViewModel: ObservableObject {

    // MARK: - Published

    @Published public var user: User?
    @Published public var family: Family?
    @Published public var allQuests: [Quest] = []
    @Published public var urgentQuests: [Quest] = []
    @Published public var myTasks: [Quest] = []
    @Published public var weeklyStats: UserStatistics?
    @Published public var recentActivities: [String] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    @Published public var urgentCount: String = ""
    @Published public var progressText: String = "0%"
    @Published public var categoryStats: [CategoryStatistic] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - 초기화

    public init() {
        setupDataBindings()
        setupComputedProperties()
    }

    public func loadInitialData() {
        Task {
            await performDataLoad()
        }
    }

    @MainActor
    private func performDataLoad() async {
        isLoading = true
        errorMessage = nil

        do {
            async let userTask = loadUserDataAsync()
            async let familyTask = loadFamilyDataAsync()
            async let questsTask = loadQuestsDataAsync()
            async let statsTask = loadStatisticsDataAsync()
            async let activitiesTask = loadRecentActivitiesAsync()

            let (user, family, quests, stats, activities) = try await (
                userTask, familyTask, questsTask, statsTask, activitiesTask
            )

            self.user = user
            self.family = family
            self.allQuests = quests
            self.weeklyStats = stats
            self.recentActivities = activities

        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func refreshData() {
        loadInitialData()
    }

    private func setupDataBindings() {
        $allQuests
            .map { quests in
                QuestUrgencyCalculator.sortQuestsByUrgency(
                    quests.filter { $0.isDueToday || $0.isOverdue }
                )
            }
            .assign(to: &$urgentQuests)

        Publishers.CombineLatest($allQuests, $user)
            .map { [weak self] quests, user in
                guard let currentUserId = user?.id else { return [] }
                return Array(quests.filter { $0.assignedTo == currentUserId }.prefix(10))
            }
            .assign(to: &$myTasks)
    }

    private func setupComputedProperties() {
        $urgentQuests
            .map { quests in
                quests.isEmpty ? "" : "\(quests.count)개"
            }
            .assign(to: &$urgentCount)

        $weeklyStats
            .map { stats in
                guard let stats = stats else { return "0%" }
                let percentage = stats.completionRate
                return "\(Int(percentage))%"
            }
            .assign(to: &$progressText)

        $weeklyStats
            .map { stats in
                guard let stats = stats else { return [] }
                let categoryStats = [
                    CategoryStatistic(category: .cleaning, count: 3, emoji: "🧹"),
                    CategoryStatistic(category: .cooking, count: 2, emoji: "🍳"),
                    CategoryStatistic(category: .dishes, count: 1, emoji: "🍽️"),
                    CategoryStatistic(category: .laundry, count: 2, emoji: "👕"),
                    CategoryStatistic(category: .pet, count: 3, emoji: "🐶"),
                    CategoryStatistic(category: .trash, count: 1, emoji: "🗑️"),
                ]
                return categoryStats
            }
            .assign(to: &$categoryStats)
    }

    // MARK: - 데이터 로딩

    private func loadUserDataAsync() async throws -> User? {
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5초 지연
        return createDummyUser()
    }

    private func createDummyUser() -> User {
        var user = User(
            id: "user1",
            name: "심관혁",
            email: "user@example.com",
            role: .parent
        )
        user.familyId = "family1"
        user.points = 245
        user.profileImageURL = nil
        return user
    }

    private func loadFamilyDataAsync() async throws -> Family? {
        try await Task.sleep(nanoseconds: 300_000_000)  // 0.3초 지연
        return createDummyFamily()
    }

    private func createDummyFamily() -> Family {
        var family = Family(
            id: "family1",
            name: "우리 가족",
            createdBy: "user1"
        )
        family.memberIds.append("user2")
        return family
    }

    private func loadQuestsDataAsync() async throws -> [Quest] {
        try await Task.sleep(nanoseconds: 700_000_000)  // 0.7초 지연
        return createDummyQuests()
    }

    private func createDummyQuests() -> [Quest] {
        let questData: [(String, String, QuestCategory, Int, Date?)] = [
            ("설거지", "식사 후 설거지 • 1시간 전 시작", .dishes, 15,
             makeDate(daysFromNow: 0, hour: 19, minute: 00)),
            ("빨래 널기", "세탁기 완료 • 30분 전 시작", .laundry, 10,
             makeDate(daysFromNow: 0, hour: 18, minute: 30)),
            ("청소기 돌리기", "거실 청소 • 오늘까지", .cleaning, 20,
             makeDate(daysFromNow: 0, hour: 23, minute: 59)),
            ("쓰레기 배출", "분리수거 • 오늘 밤 12시까지", .trash, 5,
             makeDate(daysFromNow: 0, hour: 24, minute: 00)),
            ("약국 가기", "감기약 사오기 • 1시간 남음", .other, 10,
             makeDate(daysFromNow: 1, hour: 10, minute: 00)),
            ("강아지 산책", "30분 산책 • 2시간 지남", .pet, 8,
             makeDate(daysFromNow: -1, hour: 16, minute: 00)),
        ]

        var quests = questData.map { title, description, category, points, dueDate in
            var quest = Quest(
                title: title,
                description: description,
                category: category,
                createdBy: "user1",
                familyId: "family1",
                points: points
            )
            quest.dueDate = dueDate
            quest.assignedTo = "user1"
            return quest
        }

        // 상태 및 마감일 설정
//        quests[0].status = .inProgress
//        quests[1].status = .inProgress
//
//        let now = Date()
//        quests[3].dueDate = Calendar.current.date(byAdding: .hour, value: 6, to: now)
//        quests[4].dueDate = Calendar.current.date(byAdding: .hour, value: 1, to: now)
//        quests[5].dueDate = Calendar.current.date(byAdding: .hour, value: -2, to: now)

        return quests
    }
    
    private func makeDate(daysFromNow: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        let calendar = Calendar.current
        let now = Date()

        let today = calendar.dateComponents([.year, .month, .day], from: now)
        
        components.year = today.year
        components.month = today.month
        components.day = (today.day ?? 1) + daysFromNow
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components)!
    }

    private func loadStatisticsDataAsync() async throws -> UserStatistics? {
        try await Task.sleep(nanoseconds: 400_000_000)  // 0.4초 지연
        return UserStatistics(
            userId: "user1",
            totalQuests: 16,
            completedQuests: 12,
            weeklyPoints: 245,
            monthlyPoints: 1020,
            completionRate: 75.0,
            averageCompletionTime: 2.5,
            favoriteCategory: .cleaning,
            streak: 5
        )
    }

    private func loadRecentActivitiesAsync() async throws -> [String] {
        try await Task.sleep(nanoseconds: 600_000_000)  // 0.6초 지연
        return [
            "관혁님이 '설거지' 완료했어요",
            "예슬님이 '빨래 널기' 시작했어요",
        ]
    }
}

// TODO: - 모델로 이동

public struct CategoryStatistic {
    public let category: QuestCategory
    public let count: Int
    public let emoji: String

    public init(category: QuestCategory, count: Int, emoji: String) {
        self.category = category
        self.count = count
        self.emoji = emoji
    }
}

// MARK: - Error

public enum MainViewError: LocalizedError {
    case networkError
    case dataCorruption
    case unauthorized

    public var errorDescription: String? {
        switch self {
        case .networkError:
            return "네트워크 연결을 확인해주세요"
        case .dataCorruption:
            return "데이터를 불러올 수 없습니다"
        case .unauthorized:
            return "로그인이 필요합니다"
        }
    }
}

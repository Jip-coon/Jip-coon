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

/// 메인 화면의 비즈니스 로직과 데이터 관리를 담당하는 뷰모델
/// - MVVM 패턴 구현으로 뷰와 데이터 로직을 분리
/// - Combine 프레임워크를 활용한 반응형 데이터 바인딩
/// - 캐싱과 실시간 데이터 동기화를 통한 성능 최적화
/// - Swift Concurrency를 활용한 비동기 데이터 처리
@MainActor
public class MainViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol
    private let questService: QuestServiceProtocol

    // MARK: - Published

    @Published public var user: User?
    @Published public var family: Family?
    @Published public var familyMembers: [User] = []
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
    @Published public var pendingApprovalCount: Int = 0

    // MARK: - 캐싱 데이터

    private var isInitialDataLoaded = false
    private var lastRefreshTime: Date?
    private let refreshInterval: TimeInterval = 300 // 5분
    private var isViewVisible = false

    private var cancellables = Set<AnyCancellable>()
    private var questSubscription: AnyCancellable?

    // MARK: - 초기화

    /// 의존성 주입을 통한 뷰모델 초기화
    /// - Parameters:
    ///   - userService: 사용자 데이터 관리를 위한 프로토콜 준수 객체
    ///   - familyService: 가족 데이터 관리를 위한 프로토콜 준수 객체
    ///   - questService: 퀘스트 데이터 관리를 위한 프로토콜 준수 객체
    /// - Note: 초기화 시 데이터 바인딩과 계산 속성 설정을 자동으로 수행
    ///         @MainActor를 통해 모든 작업을 메인 스레드에서 수행하도록 보장
    public init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.userService = userService
        self.familyService = familyService
        self.questService = questService
        setupDataBindings()
        setupComputedProperties()
    }

    /// 초기 데이터 로딩을 수행하는 메소드
    /// - Parameter forceRefresh: 캐시를 무시하고 강제 데이터 새로고침 여부
    /// - Note: 캐싱 메커니즘을 활용하여 불필요한 네트워크 요청 방지
    ///        Swift Concurrency의 Task를 사용하여 비동기 실행
    public func loadInitialData(forceRefresh: Bool = false) {
        // 캐시 유효성 검사: 강제 리프레시가 아니고 이미 로드되었으며 캐시가 유효하면 중복 로딩 방지
        if !forceRefresh && isInitialDataLoaded && !shouldRefreshData() {
            return
        }

        Task {
            await performDataLoad()
        }
    }

    public func refreshDataIfNeeded() {
        // 뷰가 보이는 상태에서만 리프레시 수행
        guard isViewVisible else { return }

        // 마지막 리프레시로부터 충분한 시간이 지났거나 초기 데이터가 로드되지 않은 경우에만 리프레시
        if !isInitialDataLoaded || shouldRefreshData() {
            loadInitialData()
        }
    }

    /// 외부에서 강제 데이터 리프레시 요청 (예: 퀘스트 생성 후)
    public func forceRefreshData() {
        loadInitialData(forceRefresh: true) // 강제 리프레시
    }

    /// 실제 데이터 로딩 작업을 수행하는 메소드
    /// - 여러 데이터 소스를 동시에 로딩하여 성능 최적화 (async let 활용)
    /// - 사용자, 가족, 퀘스트, 통계, 활동 데이터를 한 번에 조회
    /// - 로딩 상태 관리 및 에러 핸들링 수행
    /// - 실시간 데이터 관찰 설정으로 데이터 동기화 시작
    @MainActor
    private func performDataLoad() async {
        isLoading = true
        errorMessage = nil

        do {
            // Swift Concurrency의 async let을 활용한 병렬 데이터 로딩
            // 네트워크 지연 시간을 최소화하기 위해 동시에 모든 데이터 조회
            async let userTask = loadUserDataAsync()
            async let familyTask = loadFamilyDataAsync()
            async let questsTask = loadQuestsDataAsync()
            async let statsTask = loadStatisticsDataAsync()
            async let activitiesTask = loadRecentActivitiesAsync()

            // 모든 비동기 작업의 결과를 동시에 기다림
            let (user, family, quests, stats, activities) = try await (
                userTask, familyTask, questsTask, statsTask, activitiesTask
            )

            // 로드된 데이터를 Published 속성에 할당하여 UI 자동 업데이트
            self.user = user
            self.family = family

            // 가족 ID를 통해 가족 구성원 정보 추가 로딩
            if let familyId = family?.id ?? user?.familyId {
                self.familyMembers = try await userService
                    .getFamilyMembers(familyId: familyId)
            }

            self.allQuests = quests
            self.weeklyStats = stats
            self.recentActivities = activities

            // 캐시 유효성 관리: 초기 로드 완료 표시 및 타임스탬프 기록
            isInitialDataLoaded = true
            lastRefreshTime = Date()

            // Firebase 실시간 데이터베이스를 통한 실시간 업데이트 설정
            setupRealtimeQuestObservation()

        } catch {
            // 로딩 실패 시 사용자에게 에러 메시지 표시
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func refreshData() {
        // 강제 리프레시
        isInitialDataLoaded = false
        loadInitialData()
    }

    // MARK: - View State Management

    public func viewDidAppear() {
        isViewVisible = true
        refreshDataIfNeeded()
    }

    public func viewDidDisappear() {
        isViewVisible = false
    }

    // MARK: - 캐시 관리

    private func shouldRefreshData() -> Bool {
        guard let lastRefresh = lastRefreshTime else { return true }
        return Date().timeIntervalSince(lastRefresh) > refreshInterval
    }

    /// 캐시된 데이터를 무효화하고 다음 로드 시 강제 리프레시
    public func invalidateCache() {
        isInitialDataLoaded = false
        lastRefreshTime = nil
    }

    /// Combine을 활용한 데이터 바인딩 설정
    /// - Published 속성들 간의 관계를 정의하여 자동 데이터 변환 구현
    /// - 실시간 데이터 관찰 설정으로 Firebase 변경사항 즉시 반영
    /// - 계산 속성들을 통해 복잡한 데이터 필터링 및 정렬 로직 처리
    private func setupDataBindings() {
        // Firebase 실시간 데이터베이스를 통한 퀘스트 변경사항 관찰 시작
        setupRealtimeQuestObservation()

        // 긴급 퀘스트 필터링 및 긴급도 순 정렬
        // 오늘 마감이거나 기한이 지난 퀘스트들을 긴급도로 정렬하여 표시
        $allQuests
            .map { quests in
                QuestUrgencyCalculator.sortQuestsByUrgency(
                    quests.filter { $0.isDueToday || $0.isOverdue }
                )
            }
            .assign(to: &$urgentQuests)

        // 내 작업 필터링: 현재 사용자에게 할당된 작업들 (최대 10개)
        // CombineLatest를 사용하여 퀘스트 목록과 사용자 정보의 변경사항을 동시에 관찰
        Publishers.CombineLatest($allQuests, $user)
            .map {
 quests,
 user in
                guard let currentUserId = user?.id else { return [] }
                // 할당자가 없거나 현재 사용자에게 할당된 퀘스트만 필터링
                return Array(
                    quests
                        .filter { $0.assignedTo == nil || $0.assignedTo == currentUserId
                        }.prefix(10))
            }
            .assign(to: &$myTasks)
    }

    private func setupRealtimeQuestObservation() {
        // Task를 사용해서 비동기적으로 실시간 관찰 설정
        Task {
            do {
                // 현재 사용자와 가족 정보를 가져옴
                if let currentUser = try await userService.getCurrentUser(),
                   let familyId = currentUser.familyId {
                    // 정상적인 경우: 실시간 관찰 시작
                    await self.startRealtimeObservation(
                        with: currentUser,
                        familyId: familyId
                    )
                } else {
                    print("실시간 관찰: 사용자 정보 또는 가족 ID가 없어 더미 데이터로 폴백합니다")

                    // 더미 데이터를 사용한 폴백
                    let dummyUser = User(
                        id: "dummy_user_id",
                        name: "개발자",
                        email: "dev@example.com",
                        role: .parent
                    )
                    var dummyUserWithFamily = dummyUser
                    dummyUserWithFamily.familyId = "dummy_family_id"

                    await self.startRealtimeObservation(
                        with: dummyUserWithFamily,
                        familyId: "dummy_family_id"
                    )
                }
            } catch {
                print("실시간 퀘스트 관찰 설정 실패: \(error.localizedDescription)")
            }
        }
    }

    private func startRealtimeObservation(with user: User, familyId: String) async {
        print("실시간 퀘스트 관찰 시작: familyId = \(familyId)")

        do {
            // 가족 구성원 정보 로드
            let members = try await userService.getFamilyMembers(
                familyId: familyId
            )
            await MainActor.run {
                self.familyMembers = members
            }

            // 기존 구독 취소
            await MainActor.run {
                questSubscription?.cancel()
            }

            // 실시간 퀘스트 데이터 구독
            questSubscription = questService
                .observeFamilyQuests(familyId: familyId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("퀘스트 실시간 관찰 완료")
                    case .failure(let error):
                        print("퀘스트 실시간 관찰 에러: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] quests in
                    print("실시간 퀘스트 업데이트: \(quests.count)개")
                    self?.allQuests = quests
                }
        } catch {
            print("실시간 관찰 시작 실패: \(error.localizedDescription)")
        }
    }

    /// 계산 속성 설정 - 데이터 모델을 UI 표시용 값으로 변환
    /// - 긴급 퀘스트 개수를 사용자 친화적인 문자열로 변환
    /// - 주간 통계의 완료율을 퍼센트 표시로 변환
    /// - 카테고리별 통계를 시각화용 데이터로 가공
    private func setupComputedProperties() {
        // 긴급 퀘스트 개수를 표시용 문자열로 변환
        $urgentQuests
            .map { quests in
                quests.isEmpty ? "" : "\(quests.count)개"
            }
            .assign(to: &$urgentCount)

        // 주간 완료율을 퍼센트 문자열로 변환하여 프로그레스 텍스트로 표시
        $weeklyStats
            .map { stats in
                guard let stats = stats else { return "0%" }
                let percentage = stats.completionRate
                return "\(Int(percentage))%"
            }
            .assign(to: &$progressText)

        $weeklyStats
            .map { stats in
                guard let _ = stats else { return [] }
                let categoryStats = [
                    CategoryStatistic(
                        category: .cleaning,
                        count: 3,
                        emoji: "🧹"
                    ),
                    CategoryStatistic(
                        category: .cooking,
                        count: 2,
                        emoji: "🍳"
                    ),
                    CategoryStatistic(
                        category: .dishes,
                        count: 1,
                        emoji: "🍽️"
                    ),
                    CategoryStatistic(
                        category: .laundry,
                        count: 2,
                        emoji: "👕"
                    ),
                    CategoryStatistic(category: .pet, count: 3, emoji: "🐶"),
                    CategoryStatistic(category: .trash, count: 1, emoji: "🗑️"),
                ]
                return categoryStats
            }
            .assign(to: &$categoryStats)
    }

    // MARK: - 데이터 로딩

    private func loadUserDataAsync() async throws -> User? {
        let currentUser = try await userService.getCurrentUser()
        return currentUser
    }
    
    // 가족 정보 로드
    private func loadFamilyDataAsync() async throws -> Family? {
        // 현재 사용자의 가족 정보를 조회
        guard let currentUser = try await userService.getCurrentUser() else {
            // 사용자가 없는 경우 nil 반환
            return nil
        }

        // FirebaseFamilyService에서 자동으로 더미 데이터를 처리함
        return try await familyService.getUserFamily(userId: currentUser.id)
    }

    private func loadQuestsDataAsync() async throws -> [Quest] {
        // 현재 사용자의 가족 ID를 가져와서 해당 가족의 퀘스트들을 조회
        guard let currentUser = try await userService.getCurrentUser() else {
            // 사용자가 없는 경우 더미 데이터 반환
            return createDummyQuests()
        }

        let familyId = currentUser.familyId ?? "dummy_family_id"

        do {
            let quests = try await questService.getFamilyQuests(
                familyId: familyId
            )
            // 실제 데이터가 있는 경우 반환, 없으면 더미 데이터 반환
            let finalQuests = quests.isEmpty ? createDummyQuests() : quests

            // 승인 대기 카운트 계산 (현재 사용자가 생성자이고, 완료 상태인 퀘스트들)
            if let currentUser = try await userService.getCurrentUser() {
                let pendingCount = finalQuests.filter { quest in
                    quest.createdBy == currentUser.id && quest.status == .completed
                }.count
                await MainActor.run {
                    self.pendingApprovalCount = pendingCount
                }
            }

            return finalQuests
        } catch {
            // Firebase 연결 실패 시 더미 데이터로 폴백
            return createDummyQuests()
        }
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

        let quests = questData.map { title, description, category, points, dueDate in
            var quest = Quest(
                title: title,
                description: description,
                category: category,
                createdBy: "dummy_user_id",
                familyId: "dummy_family_id",
                points: points
            )
            quest.dueDate = dueDate
            quest.assignedTo = "dummy_user_id"
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
            userId: "dummy_user_id",
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

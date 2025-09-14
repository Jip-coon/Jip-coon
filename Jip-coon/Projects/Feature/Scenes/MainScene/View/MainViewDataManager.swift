//
//  MainViewDataManager.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import Core
import UI
import UIKit

public protocol MainViewDataManagerDelegate: AnyObject {
    func didLoadUserData(_ user: User?)
    func didLoadFamilyData(_ family: Family?)
    func didLoadQuests(_ quests: [Quest])
    func didLoadStatistics(_ stats: UserStatistics?)
    func didLoadRecentActivity(_ activities: [String])
    func didFailWithError(_ error: Error)
}

public class MainViewDataManager {

    public weak var delegate: MainViewDataManagerDelegate?
    private let authService = AuthService()

    // MARK: - 데이터 불러오기

    public func loadInitialData() {
        loadUserData()
        loadFamilyData()
        loadQuests()
        loadStatistics()
    }

    public func refreshData() {
        loadQuests()
        loadStatistics()
        loadRecentActivity()
    }

    private func loadUserData() {
        // TODO: - 실제 사용자 데이터 로딩 구현
        // 현재는 더미 데이터 사용
        DispatchQueue.main.async { [weak self] in
            // 임시 더미 유저 데이터
            let dummyUser = User(id: "user1", name: "심관혁", email: "test@example.com", role: .parent)
            self?.delegate?.didLoadUserData(dummyUser)
        }
    }

    private func loadFamilyData() {
        // TODO: - 실제 가족 데이터 로딩 구현
        // 현재는 더미 데이터 사용
        DispatchQueue.main.async { [weak self] in
            // 임시 더미 가족 데이터
            let dummyFamily = Family(name: "우리가족", createdBy: "user1")
            self?.delegate?.didLoadFamilyData(dummyFamily)
        }
    }

    private func loadQuests() {
        // TODO: - 실제 퀘스트 데이터 로딩 구현
        // 현재는 더미 데이터 사용
        DispatchQueue.main.async { [weak self] in
            var dummyQuests = [
                Quest(
                    title: "설거지", description: "식사 후 설거지 • 1시간 전 시작", category: .dishes, createdBy: "user1",
                    familyId: "family1", points: 15),
                Quest(
                    title: "빨래 널기", description: "세탁기 완료 • 30분 전 시작", category: .laundry, createdBy: "user1",
                    familyId: "family1", points: 10),
                Quest(
                    title: "청소기 돌리기", description: "거실 청소 • 오늘까지", category: .cleaning, createdBy: "user1",
                    familyId: "family1", points: 20),
            ]

            // 진행 중인 상태로 설정
            dummyQuests[0].status = .inProgress  // 설거지
            dummyQuests[1].status = .inProgress  // 빨래 널기
            // dummyQuests[2]는 기본값 .pending (대기)

            self?.delegate?.didLoadQuests(dummyQuests)
        }
    }

    private func loadStatistics() {
        // TODO: - 실제 통계 데이터 로딩 구현
        // 현재는 더미 데이터 사용
        DispatchQueue.main.async { [weak self] in
            let dummyStats = UserStatistics(
                userId: "user1",
                totalQuests: 16,
                completedQuests: 12,
                totalPoints: 250,
                categoryStats: [
                    "cleaning": 3,
                    "cooking": 2,
                    "dishes": 1,
                    "trash": 1,
                ]
            )
            self?.delegate?.didLoadStatistics(dummyStats)
        }
    }

    private func loadRecentActivity() {
        // TODO: - 실제 최근 활동 데이터 로딩 구현
        // 현재는 더미 데이터 사용
        DispatchQueue.main.async { [weak self] in
            let dummyActivities = [
                "✅ 예슬님이 '빨래 개기' 완료",
                "⏳ 관혁님의 '쓰레기 분리수거' 승인대기",
            ]
            self?.delegate?.didLoadRecentActivity(dummyActivities)
        }
    }

    // MARK: - Data Update Methods

    public func updateUserPoints(_ points: Int) {
        // TODO: - 사용자 포인트 업데이트 구현
    }

    public func updateQuestStatus(_ questId: String, status: QuestStatus) {
        // TODO: - 퀘스트 상태 업데이트 구현
    }

    public func createNewQuest(_ quest: Quest) {
        // TODO: - 새 퀘스트 생성 구현
    }

    public func approveQuest(_ questId: String) {
        // TODO: - 퀘스트 승인 구현
    }

    public func signOut() throws {
        try authService.signOut()
    }

    public func getCurrentUserId() -> String? {
        // TODO: - 현재 사용자 ID 반환 구현
        return "user1"  // 임시
    }

    public func getCurrentFamilyId() -> String? {
        // TODO: - 현재 가족 ID 반환 구현
        return "family1"  // 임시
    }
}

// MARK: - 데이터 포매팅

extension MainViewDataManager {

    public func formatUserDisplayName(from user: User) -> String {
        return "\(user.name) (\(user.role.displayName))"
    }

    public func formatUserPoints(from user: User) -> String {
        return "⭐ \(user.points) 포인트"
    }

    public func formatFamilyName(from family: Family) -> String {
        return "🏠 \(family.name)"
    }

    public func formatCompletionRate(completed: Int, total: Int) -> String {
        let percentage = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
        return "\(percentage)%"
    }

    public func formatCategoryStats(from stats: [String: Int]) -> String {
        let categoryEmojis: [String: String] = [
            "cleaning": "🧹청소",
            "cooking": "👨‍🍳요리",
            "dishes": "🍽️설거지",
            "trash": "🗑️쓰레기",
            "laundry": "👕빨래",
            "pet": "🐕반려동물",
            "study": "📚공부",
            "exercise": "💪운동",
            "other": "📝기타",
        ]

        return stats.compactMap { key, value in
            guard let emoji = categoryEmojis[key] else { return nil }
            return "\(emoji) \(value)개"
        }.joined(separator: " | ")
    }

    public func formatTimeRemaining(until date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)

        if timeInterval < 0 {
            return "마감됨"
        }

        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)

        if days > 0 {
            return "\(days)일 남음"
        } else if hours > 0 {
            return "\(hours)시간 남음"
        } else {
            return "곧 마감"
        }
    }

    public func formatRelativeTime(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)

        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)

        if days > 0 {
            return "\(days)일 전"
        } else if hours > 0 {
            return "\(hours)시간 전"
        } else if minutes > 0 {
            return "\(minutes)분 전"
        } else {
            return "방금 전"
        }
    }
}

//
//  UserStatistics.swift
//  Core
//
//  Created by 심관혁 on 9/19/25.
//

import Foundation

// MARK: - 사용자 통계 모델

public struct UserStatistics: Codable {
    public let userId: String  // 사용자 ID
    public var totalQuests: Int  // 총 퀘스트 수
    public var completedQuests: Int  // 완료한 퀘스트 수
    public var weeklyPoints: Int  // 주간 획득 포인트
    public var monthlyPoints: Int  // 월간 획득 포인트
    public var completionRate: Double  // 완료율 (%)
    public var averageCompletionTime: Double  // 평균 완료 시간 (시간)
    public var favoriteCategory: QuestCategory  // 선호 카테고리
    public var streak: Int  // 연속 완료 일수
    public let createdAt: Date  // 생성일
    public var updatedAt: Date  // 수정일

    public init(userId: String) {
        self.userId = userId
        self.totalQuests = 0
        self.completedQuests = 0
        self.weeklyPoints = 0
        self.monthlyPoints = 0
        self.completionRate = 0.0
        self.averageCompletionTime = 0.0
        self.favoriteCategory = .cleaning
        self.streak = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    public init(
        userId: String, totalQuests: Int, completedQuests: Int,
        weeklyPoints: Int, monthlyPoints: Int, completionRate: Double,
        averageCompletionTime: Double, favoriteCategory: QuestCategory, streak: Int
    ) {
        self.userId = userId
        self.totalQuests = totalQuests
        self.completedQuests = completedQuests
        self.weeklyPoints = weeklyPoints
        self.monthlyPoints = monthlyPoints
        self.completionRate = completionRate
        self.averageCompletionTime = averageCompletionTime
        self.favoriteCategory = favoriteCategory
        self.streak = streak
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - UserStatistics Extensions

public extension UserStatistics {
    /// 완료율 계산
    var calculatedCompletionRate: Double {
        guard totalQuests > 0 else { return 0.0 }
        return Double(completedQuests) / Double(totalQuests) * 100.0
    }

    /// 성취도 레벨 (완료율 기준)
    var achievementLevel: AchievementLevel {
        switch completionRate {
        case 90...100:
            return .excellent
        case 70..<90:
            return .good
        case 50..<70:
            return .average
        default:
            return .needsImprovement
        }
    }

    /// 이번 주 활성도가 높은지 확인
    var isActiveThisWeek: Bool {
        return weeklyPoints > 50
    }
}

// MARK: - Supporting Types

public enum AchievementLevel: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case needsImprovement = "needs_improvement"

    public var displayName: String {
        switch self {
        case .excellent:
            return "훌륭함"
        case .good:
            return "좋음"
        case .average:
            return "보통"
        case .needsImprovement:
            return "개선 필요"
        }
    }

    public var emoji: String {
        switch self {
        case .excellent:
            return "🏆"
        case .good:
            return "👍"
        case .average:
            return "👌"
        case .needsImprovement:
            return "💪"
        }
    }
}


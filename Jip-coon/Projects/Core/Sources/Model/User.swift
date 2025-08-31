//
//  User.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - 유저 모델

public struct User: Codable, Identifiable {
    public let id: String              // Firebase Auth UID
    public var name: String            // 사용자 이름
    public var email: String           // 이메일
    public var role: UserRole          // 역할 (부모/자녀)
    public var familyId: String?       // 소속 가족 ID
    public var profileImageURL: String? // 프로필 이미지 URL
    public var points: Int             // 획득 포인트
    public let createdAt: Date         // 생성일
    public var updatedAt: Date         // 수정일
    
    public init(id: String, name: String, email: String, role: UserRole) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.familyId = nil
        self.profileImageURL = nil
        self.points = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - 유저 Extensions

public extension User {
    /// 사용자가 부모인지 확인
    var isParent: Bool {
        return role == .parent
    }
    
    /// 사용자가 자녀인지 확인
    var isChild: Bool {
        return role == .child
    }
    
    /// 가족에 속해있는지 확인
    var hasFamily: Bool {
        return familyId != nil
    }
    
    /// 프로필 이미지가 있는지 확인
    var hasProfileImage: Bool {
        return profileImageURL != nil && !profileImageURL!.isEmpty
    }
    
    /// 사용자 표시명 (이름 + 역할) - 수정해도 됨
    var displayNameWithRole: String {
        return "\(name) (\(role.displayName))"
    }
}

// MARK: - 유저 통계

public struct UserStatistics: Codable {
    public let userId: String
    public let totalQuests: Int
    public let completedQuests: Int
    public let totalPoints: Int
    public let completionRate: Double
    public let categoryStats: [String: Int] // QuestCategory.rawValue: count
    public let monthlyStats: [String: Int] // "YYYY-MM": count
    public let updatedAt: Date
    
    public init(userId: String, totalQuests: Int = 0, completedQuests: Int = 0, 
                totalPoints: Int = 0, categoryStats: [String: Int] = [:], 
                monthlyStats: [String: Int] = [:]) {
        self.userId = userId
        self.totalQuests = totalQuests
        self.completedQuests = completedQuests
        self.totalPoints = totalPoints
        self.completionRate = totalQuests > 0 ? Double(completedQuests) / Double(totalQuests) : 0.0
        self.categoryStats = categoryStats
        self.monthlyStats = monthlyStats
        self.updatedAt = Date()
    }
}

public extension UserStatistics {
    /// 완료율 백분율 문자열
    var completionRatePercentage: String {
        return String(format: "%.1f%%", completionRate * 100)
    }
    
    /// 가장 많이 완료한 카테고리 문자열
    var topCategoryString: String? {
        return categoryStats.max(by: { $0.value < $1.value })?.key
    }
}

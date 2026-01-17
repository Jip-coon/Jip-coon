//
//  Family.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - 가족 모델

public struct Family: Codable, Identifiable {
    public let id: String              // 가족 고유 ID
    public var name: String            // 가족 이름
    public let inviteCode: String      // 초대 코드 (6자리) - 무슨 방법이 나을지 미정
    public var memberIds: [String]     // 구성원 ID 목록
    public let createdBy: String       // 생성자 ID
    public let createdAt: Date         // 생성일
    public var updatedAt: Date         // 수정일
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        inviteCode: String,
        createdBy: String
    ) {
        self.id = id
        self.name = name
        self.inviteCode = inviteCode
        self.memberIds = [createdBy]
        self.createdBy = createdBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // 기존 생성자 (하위 호환성 유지)
    public init(
        id: String = UUID().uuidString,
        name: String,
        createdBy: String
    ) {
        self.id = id
        self.name = name
        self.inviteCode = String(
            format: "%06d",
            Int.random(in: 100000...999999)
        )
        self.memberIds = [createdBy]
        self.createdBy = createdBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - 가족 Extension

public extension Family {
    /// 구성원 수
    var memberCount: Int {
        return memberIds.count
    }
    
    /// 특정 사용자가 구성원인지 확인
    func isMember(_ userId: String) -> Bool {
        return memberIds.contains(userId)
    }
    
    /// 특정 사용자가 생성자인지 확인
    func isCreator(_ userId: String) -> Bool {
        return createdBy == userId
    }
    
    /// 구성원 추가
    mutating func addMember(_ userId: String) {
        if !memberIds.contains(userId) {
            memberIds.append(userId)
            updatedAt = Date()
        }
    }
    
    /// 구성원 제거
    mutating func removeMember(_ userId: String) {
        memberIds.removeAll { $0 == userId }
        updatedAt = Date()
    }
    
    /// 새로운 초대코드 생성 - 임시
    mutating func generateNewInviteCode() -> String {
        let newCode = String(format: "%06d", Int.random(in: 100000...999999))
        return newCode
    }
    
    /// 초대코드 포맷팅 (3자리씩 나누어 표시)
    var formattedInviteCode: String {
        let code = inviteCode
        let index = code.index(code.startIndex, offsetBy: 3)
        return "\(code[..<index]) \(code[index...])"
    }
}

// MARK: - 가족 통계 모델

public struct FamilyStatistics {
    public let familyId: String
    public let totalQuests: Int
    public let completedQuests: Int
    public let memberStats: [String: [String: Any]] // userId: stats
    public let categoryDistribution: [String: Int] // QuestCategory.rawValue: count
    public let completionTrend: [String: Double] // "YYYY-MM"
    public let updatedAt: Date
    
    public init(familyId: String, totalQuests: Int = 0, completedQuests: Int = 0,
                memberStats: [String: [String: Any]] = [:],
                categoryDistribution: [String: Int] = [:],
                completionTrend: [String: Double] = [:]) {
        self.familyId = familyId
        self.totalQuests = totalQuests
        self.completedQuests = completedQuests
        self.memberStats = memberStats
        self.categoryDistribution = categoryDistribution
        self.completionTrend = completionTrend
        self.updatedAt = Date()
    }
}

public extension FamilyStatistics {
    /// 전체 완료율
    var overallCompletionRate: Double {
        return totalQuests > 0 ? Double(completedQuests) / Double(
            totalQuests
        ) : 0.0
    }
    
    /// 완료율 백분율 문자열
    var completionRatePercentage: String {
        return String(format: "%.1f%%", overallCompletionRate * 100)
    }
    
    /// 가장 활발한 구성원 ID
    var mostActiveUserId: String? {
        // memberStats의 값들을 비교하여 가장 활발한 사용자 찾기
        return memberStats.max { (first, second) in
            let firstCompleted = (first.value["completedQuests"] as? Int) ?? 0
            let secondCompleted = (second.value["completedQuests"] as? Int) ?? 0
            return firstCompleted < secondCompleted
        }?.key
    }
    
    /// 가장 인기있는 카테고리 문자열
    var topCategoryString: String? {
        return categoryDistribution.max(by: { $0.value < $1.value })?.key
    }
}

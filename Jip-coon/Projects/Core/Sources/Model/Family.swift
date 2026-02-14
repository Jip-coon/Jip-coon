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
}

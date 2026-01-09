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

// MARK: - 임시 사용자

public struct TempUser: Codable {
    public let id: String
    public let email: String
    public let state: String
    public let createdAt: Date

    public init(id: String, email: String, state: String, createdAt: Date) {
        self.id = id
        self.email = email
        self.state = state
        self.createdAt = createdAt
    }
}

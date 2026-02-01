//
//  FamilyManageViewModel.swift
//  Feature
//
//  Created by 심관혁 on 2/1/26.
//

import Foundation
import Core

final class FamilyManageViewModel {
    private let userService: FirebaseUserService
    private let familyService: FirebaseFamilyService
    
    private(set) var familyMembers: [User] = []
    private(set) var currentUser: User?
    private(set) var family: Family?
    
    // 가족 이름
    var familyName: String {
        return family?.name ?? "가족"
    }
    
    // 초대 코드
    var inviteCode: String {
        return family?.inviteCode ?? "----"
    }
    
    init(
        userService: FirebaseUserService = FirebaseUserService(),
        familyService: FirebaseFamilyService = FirebaseFamilyService()
    ) {
        self.userService = userService
        self.familyService = familyService
    }
    
    func loadData() async throws {
        // 현재 사용자
        currentUser = try await userService.getCurrentUser()
        
        guard let currentUser = currentUser,
              let familyId = currentUser.familyId else {
            return
        }
        
        // 가족 정보
        family = try await familyService.getFamily(by: familyId)
        
        // 구성원 목록
        familyMembers = try await userService.getFamilyMembers(familyId: familyId)
    }
    
    // 역할 변경
    func updateMemberRole(userId: String, newRole: UserRole) async throws {
        try await userService.updateUserRole(userId: userId, role: newRole)
        try await loadData()
    }
    
    // 강제 퇴장 (가족 구성원 제거)
    func removeMember(userId: String) async throws {
        guard let familyId = family?.id else { return }
        try await familyService.removeMemberFromFamily(familyId: familyId, userId: userId)
        try await loadData()
    }
    
    // 가족 이름 변경
    func updateFamilyName(newName: String) async throws {
        guard let familyId = family?.id else { return }
        try await familyService.updateFamilyName(familyId: familyId, newName: newName)
        try await loadData()
    }
    
    // 초대 코드 갱신
    func refreshInviteCode() async throws {
        guard let familyId = family?.id else { return }
        _ = try await familyService.generateNewInviteCode(familyId: familyId)
        try await loadData()
    }
    
    // 본인인지 확인
    func isCurrentUser(userId: String) -> Bool {
        return currentUser?.id == userId
    }
}

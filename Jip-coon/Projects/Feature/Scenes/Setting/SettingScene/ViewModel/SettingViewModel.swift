//
//  SettingViewModel.swift
//  Feature
//
//  Created by 심관혁 on 10/29/25.
//

import Core
import FirebaseAuth
import FirebaseFirestore
import Foundation

final class SettingViewModel {
    private let authService: AuthService
    private let userService: FirebaseUserService
    private let familyService: FirebaseFamilyService
    
    private(set) var currentUser: Core.User?
    var currentProviderID: String? {
        authService.currentUser?.providerData.first?.providerID
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var fullVersionString: String {
        "\(appVersion).\(buildNumber)"
    }
    
    init(
        authService: AuthService = AuthService(),
        userService: FirebaseUserService = FirebaseUserService(),
        familyService: FirebaseFamilyService = FirebaseFamilyService()
    ) {
        self.authService = authService
        self.userService = userService
        self.familyService = familyService
    }
    
    // MARK: - 사용자 관리
    
    // 현재 사용자 정보 로드
    func loadCurrentUser() async {
        do {
            currentUser = try await userService.getCurrentUser()
        } catch {
            print("사용자 정보 로드 실패: \(error.localizedDescription)")
        }
    }
    
    // 로그아웃 수행
    func performLogout() async throws {
        try authService.signOut()
    }
    
    // 가족 탈퇴 수행
    func performLeaveFamily() async throws {
        guard let currentUser = currentUser,
              let familyId = currentUser.familyId else {
            throw NSError(
                domain: "Setting",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 정보를 찾을 수 없습니다."]
            )
        }
        
        if currentUser.isAdmin {
            // 관리자인 경우 가족 삭제 (모든 구성원 연결 해제 및 가족 문서 삭제)
            try await familyService.deleteFamily(id: familyId)
        } else {
            // 일반 구성원인 경우 본인만 탈퇴
            try await familyService.removeMemberFromFamily(
                familyId: familyId,
                userId: currentUser.id
            )
        }
    }
    
    // 회원탈퇴 수행 (비밀번호 재인증 포함)
    func performDeleteAccount(password: String?) async throws {
        // 현재 사용자 ID 확인
        guard let userId = authService.currentUser?.uid else {
            throw NSError(
                domain: "Setting",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."]
            )
        }
        
        // 1. Firebase Auth에서 계정 삭제
        try await authService.deleteAccountWithReauth(password: password)
        
        // 2. Firestore에서 사용자 관련 데이터 삭제
        try await deleteUserData(userId: userId)
    }
    
    // 사용자 데이터 삭제
    func deleteUserData(userId: String) async throws {
        let db = Firestore.firestore()
        
        // Firestore 컬렉션 이름
        let questsCollection = FirestoreCollections.quests
        let familiesCollection = FirestoreCollections.families
        
        // 사용자가 생성한 퀘스트 삭제
        let questsQuery = db.collection(questsCollection)
            .whereField("createdBy", isEqualTo: userId)
        let questsSnapshot = try await questsQuery.getDocuments()
        for document in questsSnapshot.documents {
            try await document.reference.delete()
        }
        
        // 사용자가 담당자인 퀘스트에서 담당자 제거 (assignedTo 필드 업데이트)
        let assignedQuestsQuery = db.collection(questsCollection)
            .whereField("assignedTo", isEqualTo: userId)
        let assignedQuestsSnapshot = try await assignedQuestsQuery.getDocuments()
        for document in assignedQuestsSnapshot.documents {
            try await document.reference.updateData([
                "assignedTo": FieldValue.delete()
            ])
        }
        
        // 사용자가 속한 가족에서 제거
        if let currentUser = try await userService.getCurrentUser(),
           let familyId = currentUser.familyId {
            let familyRef = db.collection(familiesCollection).document(familyId)
            try await familyRef.updateData([
                "memberIds": FieldValue.arrayRemove([userId])
            ])
        }
        
        // 사용자 문서 삭제
        try await userService.deleteUser(id: userId)
        
        print("사용자 관련 Firestore 데이터 삭제 완료")
    }
}

//
//  SettingViewModel.swift
//  Feature
//
//  Created by 심관혁 on 10/29/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Core

final class SettingViewModel {
    private let authService: AuthService
    private let userService: FirebaseUserService

    private(set) var currentUser: Core.User?

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var fullVersionString: String {
        "\(appVersion).\(buildNumber)"
    }

    init(authService: AuthService = AuthService(),
         userService: FirebaseUserService = FirebaseUserService()) {
        self.authService = authService
        self.userService = userService
    }

    // MARK: - 사용자 관리

    // 현재 사용자 정보 로드
    func loadCurrentUser() async {
        do {
            currentUser = try await userService.getCurrentUser()
            if currentUser == nil {
                print(
                    "Firebase Auth UID: \(Auth.auth().currentUser?.uid ?? "없음")"
                )
                print("이메일: \(Auth.auth().currentUser?.email ?? "없음")")
            }
        } catch {
            print("사용자 정보 로드 실패: \(error.localizedDescription)")
            print("Firebase Auth 상태: \(Auth.auth().currentUser != nil ? "로그인됨" : "로그인되지 않음")")
        }
    }

    // 로그아웃 수행
    func performLogout() async throws {
        try authService.signOut()
    }

    // 회원탈퇴 수행 (비밀번호 재인증 포함)
    func performDeleteAccount(password: String) async throws {
        // 현재 사용자 ID 확인
        guard let userId = authService.currentUser?.uid else {
            throw NSError(
                domain: "Setting",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."]
            )
        }

        // 1. Firestore에서 사용자 관련 데이터 삭제
        try await deleteUserData(userId: userId)

        // 2. Firebase Auth에서 계정 삭제
        try await authService.deleteAccountWithReauth(password: password)
    }

    // 사용자 데이터 삭제
    func deleteUserData(userId: String) async throws {
        let db = Firestore.firestore()

        // Firestore 컬렉션 이름
        let questSubmissionsCollection = "quest_submissions"
        let questsCollection = "quests"
        let familiesCollection = "families"

        // 사용자의 퀘스트 데이터 삭제
        let submissionsQuery = db.collection(questSubmissionsCollection)
            .whereField("userId", isEqualTo: userId)
        let submissionsSnapshot = try await submissionsQuery.getDocuments()
        for document in submissionsSnapshot.documents {
            try await document.reference.delete()
        }

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

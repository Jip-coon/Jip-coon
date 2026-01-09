//
//  FirebaseUserService.swift
//  Core
//
//  Created by 예슬 on 9/18/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

public final class FirebaseUserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private var usersCollection: CollectionReference {
        return db.collection(FirestoreCollections.users)
    }
    private var usersTempCollection: CollectionReference {
        db.collection(FirestoreCollections.usersTemp)
    }
    
    public init() { }
    
    /// 사용자 프로필 생성
    public func createUser(_ user: User) async throws {
        try usersCollection.document(user.id).setData(from: user)
    }
    
    /// 사용자 정보 조회
    public func getUser(by id: String) async throws -> User? {
        let document = try await usersCollection.document(id).getDocument()
        if document.exists {
            return try document.data(as: User.self)
        } else {
            return nil
        }
    }
    
    /// 사용자 정보 업데이트
    public func updateUser(_ user: User) async throws {
        try usersCollection.document(user.id).setData(from: user)
    }
    
    /// 사용자 삭제
    public func deleteUser(id: String) async throws {
        try await usersCollection.document(id).delete()
    }
    
    /// 현재 로그인한 사용자 정보 조회
    public func getCurrentUser() async throws -> User? {
        // Firebase Auth에서 현재 로그인한 사용자 정보 가져오기
        if let currentUser = Auth.auth().currentUser {
            return try await getUser(by: currentUser.uid)
        } else {
            // 개발용: 로그인한 사용자가 없으면 더미 사용자 반환
            var dummyUser = User(
                id: "dummy_user_id",
                name: "개발자",
                email: "dev@example.com",
                role: .parent
            )
            dummyUser.familyId = "dummy_family_id"  // 더미 가족 ID 설정
            return dummyUser
        }
    }
    
    /// 사용자 정보가 없으면 사용자 생성
    public func syncCurrentUserDocument() async throws {
        guard let authUser = Auth.auth().currentUser else { return }
        
        // Firestore에 User 있는지 조회
        if let existingUser = try await getUser(by: authUser.uid) {
            var updatedUser = existingUser
            updatedUser.updatedAt = Date()
            // 개발 단계에서는 가족 ID가 없으면 더미 가족에 자동 할당
            if updatedUser.familyId == nil {
                updatedUser.familyId = "dummy_family_id"
            }
            try await updateUser(updatedUser)
        } else {
            // 사용자가 Firestore에 없을 경우
            let displayName = authUser.displayName ?? (
                authUser.email?
                    .split(separator: "@").first
                    .map(String.init) ?? "사용자"
            )
            // TODO: - 역할 수정하기(일단 child로 설정)
            var newUser = User(
                id: authUser.uid,
                name: displayName,
                email: authUser.email ?? "",
                role: .child
            )
            // 개발 단계에서는 자동으로 더미 가족에 할당
            newUser.familyId = "dummy_family_id"
            try await createUser(newUser)
        }
    }
    
    /// 사용자 포인트 업데이트
    public func updateUserPoints(userId: String, points: Int) async throws {
        try await usersCollection
            .document(userId)
            .updateData(["points": points])
    }
    
    /// 가족 구성원 목록 조회
    public func getFamilyMembers(familyId: String) async throws -> [User] {
        // 개발용 더미 가족 처리
        if familyId == "dummy_family_id" {
            return createDummyFamilyMembers()
        }

        // familyId와 일치하는 문서 가져오기
        let snapshot = try await usersCollection.whereField("familyId", isEqualTo: familyId).getDocuments()

        let users = snapshot.documents.compactMap { document in
            return try? document.data(as: User.self)
        }

        return users
    }

    /// 개발용 더미 가족 구성원 생성
    private func createDummyFamilyMembers() -> [User] {
        let parent = User(
            id: "dummy_parent_id",
            name: "아빠",
            email: "parent@example.com",
            role: .parent
        )
        var parentWithFamily = parent
        parentWithFamily.familyId = "dummy_family_id"
        parentWithFamily.points = 150 // 포인트 예시

        var child1 = User(
            id: "dummy_child1_id",
            name: "철수",
            email: "child1@example.com",
            role: .child
        )
        child1.familyId = "dummy_family_id"
        child1.points = 120

        var child2 = User(
            id: "dummy_child2_id",
            name: "영희",
            email: "child2@example.com",
            role: .child
        )
        child2.familyId = "dummy_family_id"
        child2.points = 95

        var child3 = User(
            id: "dummy_child3_id",
            name: "민수",
            email: "child3@example.com",
            role: .child
        )
        child3.familyId = "dummy_family_id"
        child3.points = 80

        return [parentWithFamily, child1, child2, child3]
    }
    
    /// 사용자 이름 업데이트
    public func updateUserName(userId: String, newName: String) async throws {
        let userDocRef = usersCollection.document(userId)
        
        try await userDocRef.updateData([
            "name": newName,
            "updatedAt": Timestamp(date: Date())
        ])
    }
    
    // MARK: - 임시 회원 관리(이메일 인증시 사용)
    
    /// 임시 사용자 생성
    public func createTempUser(uid: String, email: String) async throws {
        let tempUser = TempUser(
            id: uid,
            email: email,
            state: "verification_sent",
            createdAt: Date()
        )

        try usersTempCollection.document(uid).setData(from: tempUser)
    }
    
    /// 임시 사용자 조회
    public func getTempUser(by uid: String) async throws -> TempUser? {
        let document = try await usersTempCollection.document(uid).getDocument()
        return try document.data(as: TempUser.self)
    }
    
    /// 임시 사용자 삭제
    public func deleteTempUser(uid: String) async throws {
        try await usersTempCollection.document(uid).delete()
    }
}

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
        guard let currentUser = Auth.auth().currentUser else {
            // 로그인한 사용자가 없으면 nil 반환
            return nil
        }
        return try await getUser(by: currentUser.uid)
    }
    
    /// 사용자 정보가 없으면 사용자 생성
    public func syncCurrentUserDocument() async throws {
        guard let authUser = Auth.auth().currentUser else { return }
        
        // Firestore에 User 있는지 조회
        if let existingUser = try await getUser(by: authUser.uid) {
            var updatedUser = existingUser
            updatedUser.updatedAt = Date()
            try await updateUser(updatedUser)
        } else {
            // 사용자가 Firestore에 없을 경우
            let displayName = authUser.displayName ?? (authUser.email?.split(separator: "@").first.map(String.init) ?? "사용자")
            // TODO: - 역할 수정하기(일단 child로 설정)
            let newUser = User(
                id: authUser.uid,
                name: displayName,
                email: authUser.email ?? "",
                role: .child
            )
            try await createUser(newUser)
        }
    }
    
    /// 사용자 포인트 업데이트
    public func updateUserPoints(userId: String, points: Int) async throws {
        try await usersCollection.document(userId).updateData(["points": points])
    }
    
    /// 가족 구성원 목록 조회
    public func getFamilyMembers(familyId: String) async throws -> [User] {
        // familyId와 일치하는 문서 가져오기
        let snapshot = try await usersCollection.whereField("familyId", isEqualTo: familyId).getDocuments()
        
        let users = snapshot.documents.compactMap { document in
            return try? document.data(as: User.self)
        }
        
        return users
    }
    
}

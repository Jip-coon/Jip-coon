//
//  FirebaseUserService.swift
//  Core
//
//  Created by 예슬 on 9/18/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

public final class FirebaseUserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    
    private var usersCollection: CollectionReference {
        return db.collection(FirestoreCollections.users)
    }
    
    private var usersTempCollection: CollectionReference {
        db.collection(FirestoreCollections.usersTemp)
    }
    
    public init() { }
    
    // MARK: - CRUD
    
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
    
    /// 현재 로그인한 사용자의 Firestore 문서 존재 여부 확인 및 자동 생성
    /// - Firebase Auth 사용자이지만 Firestore 문서가 없는 경우 새 문서 생성
    /// - 앱 시작 시 또는 로그인 후 사용자 데이터 일관성 확보를 위해 사용
    /// - Note: 사용자 등록 프로세스의 일부로 자동 실행됨
    public func syncCurrentUserDocument() async throws {
        guard let authUser = Auth.auth().currentUser else { return }
        
        // Firestore에 User 있는지 조회
        if let existingUser = try await getUser(by: authUser.uid) {
            var updatedUser = existingUser
            updatedUser.updatedAt = Date()
            
            try await updateUser(updatedUser)
        } else {
            // 사용자가 Firestore에 없을 경우
            let displayName = authUser.displayName ?? (
                authUser.email?
                    .split(separator: "@").first
                    .map(String.init) ?? "사용자"
            )
            
            let newUser = User(
                id: authUser.uid,
                name: displayName,
                email: authUser.email ?? "",
                role: .child
            )
            
            try await createUser(newUser)
        }
    }
    
    // MARK: - Query
    
    /// 현재 Firebase Auth로 로그인한 사용자의 Firestore 문서 조회
    /// - Returns: 현재 사용자 정보 또는 nil (로그인하지 않은 경우)
    /// - Note: Firebase Auth UID를 키로 사용하여 Firestore에서 사용자 문서 검색
    ///         앱 전반에서 현재 사용자 정보를 얻기 위한 핵심 메소드
    public func getCurrentUser() async throws -> User? {
        // Firebase Auth에서 현재 로그인한 사용자 정보 가져오기
        if let currentUser = Auth.auth().currentUser {
            return try await getUser(by: currentUser.uid)
        } else {
            print("현재 로그인한 사용자 정보를 가져올 수 없습니다.")
            return nil
        }
    }
    
    /// 가족 구성원 목록 조회
    public func getFamilyMembers(familyId: String) async throws -> [User] {
        // familyId와 일치하는 문서 가져오기
        let snapshot = try await usersCollection
            .whereField(FirestoreFields.User.familyId, isEqualTo: familyId)
            .getDocuments()
        
        let users = snapshot.documents.compactMap { document in
            return try? document.data(as: User.self)
        }
        
        return users
    }
    
    // MARK: - Update
    
    /// 사용자 포인트 업데이트
    public func updateUserPoints(userId: String, points: Int) async throws {
        try await usersCollection
            .document(userId)
            .updateData([FirestoreFields.User.points: FieldValue.increment(Int64(points))])
    }
    
    /// 사용자 이름 업데이트
    public func updateUserName(userId: String, newName: String) async throws {
        let userDocRef = usersCollection.document(userId)
        
        try await userDocRef.updateData([
            FirestoreFields.User.name: newName,
            FirestoreFields.User.updatedAt: Timestamp(date: Date())
        ])
    }
    
    /// 사용자 역할 업데이트
    public func updateUserRole(userId: String, role: UserRole) async throws {
        let userDocRef = usersCollection.document(userId)
        
        try await userDocRef.updateData([
            FirestoreFields.User.role: role.rawValue,
            FirestoreFields.User.updatedAt: Timestamp(date: Date())
        ])
    }
    
    /// 현재 폰의 타임존을 가져와서 DB에 저장하는 역할
    public func updateUserTimeZone(userId: String) async {
        // 폰 설정에서 타임존 식별자 추출 (예: "Asia/Seoul")
        let timeZoneIdentifier = TimeZone.current.identifier
        
        let userRef = usersCollection.document(userId)
        
        do {
            try await userRef.updateData([
                "timeZone": timeZoneIdentifier
            ])
        } catch {
            print("타임존 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    /// 사용자의 알림 설정 업데이트
    public func updateNotificationSetting(fieldName: String, isOn: Bool) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = usersCollection.document(userId)
        
        try await userRef.updateData([
            "notificationSetting.\(fieldName)": isOn
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
    
    /// 임시 사용자 삭제
    public func deleteTempUser(uid: String) async throws {
        try await usersTempCollection.document(uid).delete()
    }
}

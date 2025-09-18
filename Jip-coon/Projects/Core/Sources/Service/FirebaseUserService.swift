//
//  FirebaseUserService.swift
//  Core
//
//  Created by 예슬 on 9/18/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final public class FirebaseUserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private let usersCollection = FirestoreCollections.users
    private let userField = FirestoreFields.User.self
    
    public init() { }
    
    /// 사용자 프로필 생성
    public func createUser(_ user: User) async throws {
        try db.collection(usersCollection).document(user.id).setData(from: user)
    }
    
    /// 사용자 정보 조회
    func getUser(by id: String) async throws -> User? {
        return nil
    }
    
    /// 사용자 정보 업데이트
    func updateUser(_ user: User) async throws {
        print("")
    }
    
    /// 사용자 삭제
    func deleteUser(id: String) async throws {
        print("")
    }
    
    /// 현재 로그인한 사용자 정보 조회
    func getCurrentUser() async throws -> User? {
        return nil
    }
    
    /// 사용자 포인트 업데이트
    func updateUserPoints(userId: String, points: Int) async throws {
        print("")
    }
    
    /// 가족 구성원 목록 조회
    func getFamilyMembers(familyId: String) async throws -> [User] {
        return []
    }
    
    
}

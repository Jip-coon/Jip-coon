//
//  FirebaseFamilyService.swift
//  Core
//
//  Created by 예슬 on 11/29/25.
//

import Foundation
import FirebaseFirestore

public final class FirebaseFamilyService: FamilyServiceProtocol {
    private let db = Firestore.firestore()
    private var familyCollection: CollectionReference {
        return db.collection(FirestoreCollections.families)
    }
    
    private func userDocument(id: String) -> DocumentReference {
        return db.collection(FirestoreCollections.users).document(id)
    }
    
    public init() {}
    
    // MARK: - CRUD
    
    /// 가족 생성
    public func createFamily(name: String, createdBy: String) async throws -> Family {
        // 중복되지 않는 초대코드 생성
        let inviteCode = try await generateUniqueInviteCode()

        // 가족 객체 생성
        let family = Family(
            id: UUID().uuidString,
            name: name,
            inviteCode: inviteCode,
            createdBy: createdBy
        )

        // Firestore에 저장
        let docRef = familyCollection.document(family.id)
        try docRef.setData(from: family)

        // 생성자의 familyId 및 관리자 권한 업데이트
        try await userDocument(id: createdBy).updateData([
            "familyId": family.id,
            "admin": true,
            "role": "parent",
            "updatedAt": Timestamp(date: Date())
        ])

        return family
    }

    /// 중복되지 않는 초대코드 생성
    private func generateUniqueInviteCode() async throws -> String {
        var newCode: String
        var attempts = 0
        let maxAttempts = 10

        repeat {
            newCode = String(format: "%06d", Int.random(in: 100000...999999))
            let existingFamily = try await getFamilyByInviteCode(newCode)

            if existingFamily == nil {
                return newCode
            }

            attempts += 1
            if attempts >= maxAttempts {
                throw NSError(
                    domain: "FamilyService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "초대코드 생성에 실패했습니다. 다시 시도해주세요."]
                )
            }
        } while true
    }
    
    /// 가족 정보 조회
    public func getFamily(by id: String) async throws -> Family? {
        let document = try await familyCollection.document(id).getDocument()
        
        guard document.exists else { return nil }
        
        return try document.data(as: Family.self)
    }
    
    /// 가족 정보 업데이트
    public func updateFamily(_ family: Family) async throws {
        try familyCollection.document(family.id).setData(from: family)
    }
    
    /// 가족 이름 업데이트
    public func updateFamilyName(familyId: String, newName: String) async throws {
        try await familyCollection.document(familyId).updateData([
            "name": newName,
            "updatedAt": Timestamp(date: Date())
        ])
    }
    
    /// 가족 삭제
    public func deleteFamily(id: String) async throws {
        // 가족 정보 조회
        guard let family = try await getFamily(by: id) else {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 정보를 찾을 수 없습니다."]
            )
        }
        
        // 모든 구성원의 familyId 제거
        for memberId in family.memberIds {
            try await updateUserFamilyId(userId: memberId, familyId: nil)
        }
        
        // 가족 문서 삭제
        let docRef = familyCollection.document(id)
        try await docRef.delete()
    }
    
    // MARK: - 조회
    
    /// 초대코드로 가족 조회
    public func getFamilyByInviteCode(_ inviteCode: String) async throws -> Family? {
        let query = familyCollection
            .whereField("inviteCode", isEqualTo: inviteCode)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            return nil
        }
        
        return try document.data(as: Family.self)
    }
    
    /// 사용자의 가족 정보 조회
    public func getUserFamily(userId: String) async throws -> Family? {
        // 사용자 정보 조회
        let userSnapshot = try await userDocument(id: userId).getDocument()

        guard userSnapshot.exists,
              let user = try? userSnapshot.data(as: User.self),
              let familyId = user.familyId else {
            return nil
        }

        // 가족 정보 조회
        return try await getFamily(by: familyId)
    }

    
    // MARK: - 구성원 및 초대코드 관리
    
    /// 초대코드로 가족 참여
    public func joinFamily(inviteCode: String, userId: String) async throws -> Family {
        // 초대코드로 가족 조회
        guard let family = try await getFamilyByInviteCode(inviteCode) else {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 초대코드입니다."]
            )
        }

        // 이미 구성원인지 확인
        if family.isMember(userId) {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "이미 가족 구성원입니다."]
            )
        }

        // 가족에 구성원 추가
        var updatedFamily = family
        updatedFamily.addMember(userId)
        try await updateFamily(updatedFamily)

        // 사용자의 familyId 업데이트
        try await updateUserFamilyId(userId: userId, familyId: family.id)

        return updatedFamily
    }

    /// 가족에 구성원 추가
    public func addMemberToFamily(familyId: String, userId: String) async throws {
        guard var family = try await getFamily(by: familyId) else {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 정보를 찾을 수 없습니다."]
            )
        }
        
        // 이미 구성원인지 확인
        if family.isMember(userId) {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "이미 가족 구성원입니다."]
            )
        }
        
        // 가족에 구성원 추가
        family.addMember(userId)
        try await updateFamily(family)
        
        // 사용자의 familyId 업데이트
        try await updateUserFamilyId(userId: userId, familyId: familyId)
    }
    
    /// 가족에서 구성원 제거
    public func removeMemberFromFamily(familyId: String, userId: String) async throws {
        guard var family = try await getFamily(by: familyId) else {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 정보를 찾을 수 없습니다."]
            )
        }
        
        // 생성자는 제거할 수 없음
        if family.isCreator(userId) {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 생성자는 제거할 수 없습니다. 가족을 삭제해주세요."]
            )
        }
        
        // 구성원이 아닌 경우
        if !family.isMember(userId) {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 구성원이 아닙니다."]
            )
        }
        
        // 가족에서 구성원 제거
        family.removeMember(userId)
        try await updateFamily(family)
        
        // 사용자의 familyId 제거
        try await updateUserFamilyId(userId: userId, familyId: nil)
    }
    
    /// 새로운 초대코드 생성
    public func generateNewInviteCode(familyId: String) async throws -> String {
        guard var _ = try await getFamily(by: familyId) else {
            throw NSError(
                domain: "FamilyService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "가족 정보를 찾을 수 없습니다."]
            )
        }
        
        // 중복되지 않는 초대코드 생성
        var newCode: String
        var attempts = 0
        let maxAttempts = 10
        
        repeat {
            newCode = String(format: "%06d", Int.random(in: 100000...999999))
            let existingFamily = try await getFamilyByInviteCode(newCode)
            
            if existingFamily == nil {
                break
            }
            
            attempts += 1
            if attempts >= maxAttempts {
                throw NSError(
                    domain: "FamilyService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "초대코드 생성에 실패했습니다. 다시 시도해주세요."]
                )
            }
        } while true
        
        // 가족 정보 업데이트
        let docRef = familyCollection.document(familyId)
        try await docRef.updateData([
            "inviteCode": newCode,
            "updatedAt": Timestamp(date: Date())
        ])
        
        return newCode
    }
    
    // MARK: - Helper Methods
    
    /// 사용자의 familyId 업데이트
    private func updateUserFamilyId(userId: String, familyId: String?) async throws {
        let userDocRef = userDocument(id: userId)
        
        if let familyId = familyId {
            try await userDocRef.updateData([
                "familyId": familyId,
                "updatedAt": Timestamp(date: Date())
            ])
        } else {
            try await userDocRef.updateData([
                "familyId": FieldValue.delete(),
                "admin": false,
                "points": 0,
                "role": "child",
                "updatedAt": Timestamp(date: Date())
            ])
        }
    }
}

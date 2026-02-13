//
//  ServiceProtocols.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Combine
import Foundation

/// 앱의 모든 서비스 레이어 인터페이스를 정의하는 프로토콜 파일
/// - 의존성 주입을 위한 프로토콜 기반 아키텍처 구현
/// - 각 서비스의 계약을 명확히 정의하여 코드 일관성 및 테스트 용이성 확보
/// - Firebase, 로컬 저장소 등 다양한 구현체 교체 가능하도록 설계
/// - Combine Publisher를 활용한 반응형 데이터 스트리밍 지원

// MARK: - 사용자 데이터 관리 서비스 프로토콜

/// 사용자 정보의 생성, 조회, 수정, 삭제를 담당하는 서비스 인터페이스
/// - Firebase Auth와 Firestore를 연동한 사용자 데이터 관리
/// - 가족 구성원 관리 및 포인트 시스템 지원
/// - 현재 사용자 세션 관리 및 자동 동기화 기능
public protocol UserServiceProtocol {
    /// 사용자 프로필 생성
    func createUser(_ user: User) async throws
    
    /// 사용자 정보 조회
    func getUser(by id: String) async throws -> User?
    
    /// 사용자 정보 업데이트
    func updateUser(_ user: User) async throws
    
    /// 사용자 삭제
    func deleteUser(id: String) async throws
    
    /// 사용자 정보가 없으면 사용자 생성
    func syncCurrentUserDocument() async throws
    
    /// 현재 로그인한 사용자 정보 조회
    func getCurrentUser() async throws -> User?
    
    /// 가족 구성원 목록 조회
    func getFamilyMembers(familyId: String) async throws -> [User]
    
    /// 사용자 포인트 업데이트
    func updateUserPoints(userId: String, points: Int) async throws
    
    /// 사용자 이름 업데이트
    func updateUserName(userId: String, newName: String) async throws
    
    /// 사용자 역할 업데이트
    func updateUserRole(userId: String, role: UserRole) async throws
    
    /// 사용자 타임존 업데이트
    func updateUserTimeZone(userId: String) async
    
    /// 알림 설정 업데이트
    func updateNotificationSetting(fieldName: String, isOn: Bool) async throws
    
    /// 임시 사용자 생성
    func createTempUser(uid: String, email: String) async throws
    
    /// 임시 사용자 삭제
    func deleteTempUser(uid: String) async throws
}

// MARK: - 가족 서비스 프로토콜

public protocol FamilyServiceProtocol {
    /// 가족 생성
    func createFamily(name: String, createdBy: String) async throws -> Family
    
    /// 가족 정보 조회
    func getFamily(by id: String) async throws -> Family?
    
    /// 가족 정보 업데이트
    func updateFamily(_ family: Family) async throws
    
    /// 가족 삭제
    func deleteFamily(id: String) async throws
    
    /// 초대코드로 가족 참여
    func joinFamily(inviteCode: String, userId: String) async throws -> Family
    
    /// 가족에서 구성원 제거
    func removeMemberFromFamily(familyId: String, userId: String) async throws
}

// MARK: - 퀘스트 데이터 관리 서비스 프로토콜

/// 퀘스트의 생성, 조회, 상태 관리, 실시간 관찰을 담당하는 서비스 인터페이스
/// - Firebase Firestore 기반 퀘스트 CRUD 작업
/// - 가족별/상태별 필터링 및 정렬 지원
/// - 실시간 데이터 동기화를 위한 Combine Publisher 제공
/// - 퀘스트 생명주기 관리 (생성 → 할당 → 진행 → 완료 → 승인)
/// - 반복 퀘스트 및 제출/승인 워크플로우 지원
public protocol QuestServiceProtocol {
    /// 퀘스트 생성
    func createQuest(_ quest: Quest) async throws -> Quest
    
    /// 퀘스트 조회
    func getQuest(by id: String) async throws -> Quest?
    
    /// 퀘스트 업데이트
    func updateQuest(_ quest: Quest) async throws
    
    /// 퀘스트 삭제
    func deleteQuest(quest: Quest, mode: DeleteMode) async throws
    
    /// 가족의 모든 퀘스트 조회
    func getFamilyQuests(familyId: String) async throws -> [Quest]
    
    /// 상태별 퀘스트 조회
    func getQuestsByStatus(familyId: String, status: QuestStatus) async throws -> [Quest]
    
    /// 퀘스트 템플릿 조회
    func fetchQuestTemplates(familyId: String) async throws -> [QuestTemplate]
    
    /// 퀘스트 상태 변경
    func updateQuestStatus(quest: Quest, status: QuestStatus) async throws
    
    /// 퀘스트 시작
    func startQuest(quest: Quest, userId: String) async throws

    /// 퀘스트의 완료 여부를 검토(승인/거절)합니다.
    func reviewQuest(questId: String, isApproved: Bool, reviewerId: String, userService: UserServiceProtocol) async throws
    
    /// 반복 퀘스트 생성
    func createQuestTemplate(_ template: QuestTemplate) async throws
    
    /// 퀘스트 조회 (병합 로직)
    func fetchQuestsWithRepeat(familyId: String, startDate: Date, endDate: Date) async throws -> [Quest]
    
    /// 가족의 퀘스트 목록을 실시간으로 관찰하는 Publisher 제공
    func observeFamilyQuests(familyId: String) -> AnyPublisher<[Quest], Error>
    
    /// 알림 배지 초기화
    func resetUserBadgeCount()
}

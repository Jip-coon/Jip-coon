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

    /// 현재 로그인한 사용자의 Firestore 문서 존재 여부 확인 및 자동 생성
    /// - Firebase Auth 사용자이지만 Firestore 문서가 없는 경우 새 문서 생성
    /// - 앱 시작 시 또는 로그인 후 사용자 데이터 일관성 확보를 위해 사용
    /// - Note: 사용자 등록 프로세스의 일부로 자동 실행됨
    func syncCurrentUserDocument() async throws
    
    /// 현재 Firebase Auth로 로그인한 사용자의 Firestore 문서 조회
    /// - Returns: 현재 사용자 정보 또는 nil (로그인하지 않은 경우)
    /// - Note: Firebase Auth UID를 키로 사용하여 Firestore에서 사용자 문서 검색
    ///         앱 전반에서 현재 사용자 정보를 얻기 위한 핵심 메소드
    func getCurrentUser() async throws -> User?
    
    /// 가족 구성원 목록 조회
    func getFamilyMembers(familyId: String) async throws -> [User]
    
    /// 사용자 포인트 업데이트
    func updateUserPoints(userId: String, points: Int) async throws
    
    /// 사용자 이름 업데이트
    func updateUserName(userId: String, newName: String) async throws
    
    /// 사용자 타임존 업데이트
    func updateUserTimeZone(userId: String) async
    
    /// 알림 설정 업데이트
    func updateNotificationSetting(fieldName: String, isOn: Bool) async throws
    
    /// 임시 사용자 생성
    func createTempUser(uid: String, email: String) async throws
    
    /// 임시 사용자 조회
    func getTempUser(by uid: String) async throws -> TempUser?
    
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
/// - 가족별/상태별/카테고리별 필터링 및 정렬 지원
/// - 실시간 데이터 동기화를 위한 Combine Publisher 제공
/// - 퀘스트 생명주기 관리 (생성 → 할당 → 진행 → 완료 → 승인)
/// - 반복 퀘스트 및 제출/승인 워크플로우 지원
public protocol QuestServiceProtocol {
    
    // MARK: - CRUD
    
    /// 퀘스트 생성
    func createQuest(_ quest: Quest) async throws -> Quest
    
    /// 퀘스트 조회
    func getQuest(by id: String) async throws -> Quest?
    
    /// 퀘스트 업데이트
    func updateQuest(_ quest: Quest) async throws
    
    /// 퀘스트 삭제
    func deleteQuest(quest: Quest, mode: DeleteMode) async throws
    
    // MARK: - 조회
    
    /// 가족의 모든 퀘스트 조회
    func getFamilyQuests(familyId: String) async throws -> [Quest]
    
    /// 상태별 퀘스트 조회
    func getQuestsByStatus(familyId: String, status: QuestStatus) async throws -> [Quest]
    
    /// 퀘스트 템플릿 조회
    func fetchQuestTemplates(familyId: String) async throws -> [QuestTemplate]
    
    // MARK: - 상태 변경
    
    /// 퀘스트 상태 변경
    func updateQuestStatus(quest: Quest, status: QuestStatus) async throws
    
    /// 퀘스트 시작
    func startQuest(quest: Quest, userId: String) async throws
    
    /// 퀘스트 완료 제출
    func submitQuestCompletion(quest: Quest, submission: QuestSubmission) async throws
    
    /// 퀘스트 승인/거절
    func reviewQuest(questId: String, isApproved: Bool, reviewComment: String?, reviewerId: String, userService: UserServiceProtocol) async throws
    
    // MARK: - 반복 퀘스트
    
    /// 반복 퀘스트 생성
    func createQuestTemplate(_ template: QuestTemplate) async throws
    
    /// 퀘스트 조회 (병합 로직)
    func fetchQuestsWithRepeat(familyId: String, startDate: Date, endDate: Date) async throws -> [Quest]
    
    // MARK: - 실시간 관찰 & 알림
    
    /// 가족의 퀘스트 목록을 실시간으로 관찰하는 Publisher 제공
    func observeFamilyQuests(familyId: String) -> AnyPublisher<[Quest], Error>
    
    /// 알림 배지 초기화
    func resetUserBadgeCount()
}

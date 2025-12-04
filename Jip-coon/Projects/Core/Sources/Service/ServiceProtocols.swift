//
//  ServiceProtocols.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation
import Combine

// MARK: - 사용자 서비스 프로토콜

public protocol UserServiceProtocol {
    /// 사용자 프로필 생성
    func createUser(_ user: User) async throws
    
    /// 사용자 정보 조회
    func getUser(by id: String) async throws -> User?
    
    /// 사용자 정보 업데이트
    func updateUser(_ user: User) async throws
    
    /// 사용자 삭제
    func deleteUser(id: String) async throws
    
    /// 현재 로그인한 사용자 정보 조회
    func getCurrentUser() async throws -> User?
    
    /// 사용자 정보가 없으면 사용자 생성
    func syncCurrentUserDocument() async throws
    
    /// 사용자 포인트 업데이트
    func updateUserPoints(userId: String, points: Int) async throws
    
    /// 가족 구성원 목록 조회
    func getFamilyMembers(familyId: String) async throws -> [User]
    
    /// 사용자 이름 업데이트
    func updateUserName(userId: String, newName: String) async throws
}

// MARK: - 가족 서비스 프로토콜

public protocol FamilyServiceProtocol {
    /// 가족 생성
    func createFamily(_ family: Family) async throws -> Family
    
    /// 가족 정보 조회
    func getFamily(by id: String) async throws -> Family?
    
    /// 초대코드로 가족 조회
    func getFamilyByInviteCode(_ inviteCode: String) async throws -> Family?
    
    /// 가족 정보 업데이트
    func updateFamily(_ family: Family) async throws
    
    /// 가족 삭제
    func deleteFamily(id: String) async throws
    
    /// 가족에 구성원 추가
    func addMemberToFamily(familyId: String, userId: String) async throws
    
    /// 가족에서 구성원 제거
    func removeMemberFromFamily(familyId: String, userId: String) async throws
    
    /// 사용자의 가족 정보 조회
    func getUserFamily(userId: String) async throws -> Family?
    
    /// 새로운 초대코드 생성
    func generateNewInviteCode(familyId: String) async throws -> String
}

// MARK: - 퀘스트 서비스 프로토콜

protocol QuestServiceProtocol {
    /// 퀘스트 생성
    func createQuest(_ quest: Quest) async throws -> Quest
    
    /// 퀘스트 조회
    func getQuest(by id: String) async throws -> Quest?
    
    /// 퀘스트 업데이트
    func updateQuest(_ quest: Quest) async throws
    
    /// 퀘스트 삭제
    func deleteQuest(id: String) async throws
    
    /// 가족의 모든 퀘스트 조회
    func getFamilyQuests(familyId: String) async throws -> [Quest]
    
    /// 상태별 퀘스트 조회
    func getQuestsByStatus(familyId: String, status: QuestStatus) async throws -> [Quest]
    
    /// 카테고리별 퀘스트 조회
    func getQuestsByCategory(familyId: String, category: QuestCategory) async throws -> [Quest]
    
    /// 담당자별 퀘스트 조회
    func getQuestsByAssignee(userId: String) async throws -> [Quest]
    
    /// 퀘스트 상태 변경
    func updateQuestStatus(questId: String, status: QuestStatus) async throws
    
    /// 퀘스트 담당자 지정
    func assignQuest(questId: String, userId: String) async throws
    
    /// 퀘스트 시작
    func startQuest(questId: String, userId: String) async throws
    
    /// 퀘스트 완료 제출
    func submitQuestCompletion(questId: String, submission: QuestSubmission) async throws
    
    /// 퀘스트 승인/거절
    func reviewQuest(questId: String, isApproved: Bool, reviewComment: String?, reviewerId: String) async throws
    
    /// 반복 퀘스트 생성
    func createRecurringQuest(baseQuest: Quest, targetDate: Date) async throws -> Quest
    
    /// 실시간 퀘스트 목록 구독
    func observeFamilyQuests(familyId: String) -> AnyPublisher<[Quest], Error>
    
    /// 실시간 퀘스트 상태 구독
    func observeQuestStatus(questId: String) -> AnyPublisher<QuestStatus, Error>
}

// MARK: - 퀘스트 제출 서비스 프로토콜

protocol QuestSubmissionServiceProtocol {
    /// 제출 생성
    func createSubmission(_ submission: QuestSubmission) async throws
    
    /// 제출 조회
    func getSubmission(by id: String) async throws -> QuestSubmission?
    
    /// 퀘스트의 제출 목록 조회
    func getSubmissionsForQuest(questId: String) async throws -> [QuestSubmission]
    
    /// 제출 업데이트
    func updateSubmission(_ submission: QuestSubmission) async throws
    
    /// 제출 삭제
    func deleteSubmission(id: String) async throws
    
    /// 승인 대기 중인 제출 목록 조회
    func getPendingSubmissions(familyId: String) async throws -> [QuestSubmission]
    
    /// 사용자의 제출 이력 조회
    func getUserSubmissions(userId: String) async throws -> [QuestSubmission]
}

// MARK: - Image Service Protocol

protocol ImageServiceProtocol {
    /// 이미지 업로드
    func uploadImage(_ imageData: Data, path: String) async throws -> String
    
    /// 이미지 삭제
    func deleteImage(url: String) async throws
    
    /// 이미지 다운로드 URL 생성
    func getDownloadURL(for path: String) async throws -> String
    
    /// 이미지 압축
    func compressImage(_ imageData: Data, quality: CGFloat) -> Data?
}

// MARK: - 통계 서비스 프로토콜

protocol StatisticsServiceProtocol {
    /// 사용자 통계 조회
    func getUserStatistics(userId: String) async throws -> UserStatistics
    
    /// 가족 통계 조회
    func getFamilyStatistics(familyId: String) async throws -> FamilyStatistics
    
    /// 월별 완료율 조회
    func getMonthlyCompletionRate(userId: String, year: Int, month: Int) async throws -> Double
    
    /// 카테고리별 완료 횟수 조회
    func getCategoryCompletionCounts(userId: String) async throws -> [QuestCategory: Int]
}

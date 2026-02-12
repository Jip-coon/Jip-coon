//
//  Quest.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - 퀘스트 데이터 모델

/// 가족 관리 앱의 핵심 데이터 모델인 퀘스트를 나타내는 구조체
/// - Firestore와의 데이터 연동을 위한 Codable 프로토콜 준수
/// - SwiftUI 및 Combine과의 호환성을 위한 Identifiable 프로토콜 준수
/// - 퀘스트의 전체 생명주기 관리 (생성, 할당, 진행, 완료, 승인)
/// - 다양한 계산 속성을 통한 상태 및 날짜 정보 제공
public struct Quest: Codable, Identifiable {
    // MARK: - 기본 식별 정보
    public let id: String              // Firestore 문서 ID (고유 식별자)
    public var templateId: String?     // Quest Template ID (반복 퀘스트 연결용 ID)
    public var title: String           // 퀘스트 제목
    public var description: String?    // 퀘스트 상세 설명 (선택사항)
    
    // MARK: - 분류 및 상태 정보
    public var category: QuestCategory // 퀘스트 카테고리 (청소, 요리, 반려동물 등)
    public var status: QuestStatus     // 현재 진행 상태 (대기, 진행중, 완료, 승인, 거절)
    public var recurringType: RecurringType // 반복 유형 (없음, 일간, 주간, 월간)
    
    // MARK: - 사용자 및 가족 관련
    public var assignedTo: String?     // 담당자 사용자 ID (nil이면 미할당)
    public let createdBy: String       // 퀘스트 생성자 ID
    public let familyId: String        // 소속 가족 ID
    
    // MARK: - 보상 및 일정 정보
    public var points: Int             // 완료 시 획득 포인트
    public var dueDate: Date?          // 마감 기한 (nil이면 기한 없음)
    public var selectedRepeatDays: [Int]?   // 선택된 반복 요일
    public var recurringEndDate: Date?  // 반복 종료일
    
    // MARK: - 타임스탬프 정보
    public let createdAt: Date         // 퀘스트 생성 시각
    public var updatedAt: Date         // 마지막 수정 시각
    public var startedAt: Date?        // 퀘스트 시작 시각
    public var completedAt: Date?      // 퀘스트 완료 시각
    public var approvedAt: Date?       // 퀘스트 승인 시각
    public var lastNotifiedAt: Date?   // 마지막으로 알림 보낸 시각
    
    /// 기본 퀘스트 생성자
    /// - Parameters:
    ///   - id: Firestore에서 자동 생성된 문서 ID
    ///   - title: 퀘스트 제목
    ///   - description: 퀘스트 상세 설명 (선택사항)
    ///   - category: 퀘스트 카테고리
    ///   - createdBy: 생성자 사용자 ID
    ///   - familyId: 소속 가족 ID
    ///   - points: 완료 시 획득 포인트 (기본값: 10)
    ///   - templateId: Quest Template ID (반복 퀘스트일 경우)
    ///   - status: 퀘스트 진행 상태
    ///   - recurringType: 퀘스트 반복 유형
    ///   - assignedTo: 담당자 사용자 ID
    ///   - dueDate: 마감일
    ///   - createdAt: 퀘스트 생성 시각
    ///   - startedAt: 퀘스트 시작 시각
    ///   - completedAt: 퀘스트 완료 시각
    ///   - approvedAt: 퀘스트 승인 시각
    ///   - updatedAt: 마지막 수정 시각
    ///   - selectedRepeatDays: 반복되는 요일
    ///   - recurringEndDate: 반복 종료일
    ///   - lastNotifiedAt: 해당 퀘스트가 마지막으로 알림 보내진 시각
    /// - Note: FirebaseQuestService에서 퀘스트 생성 시 사용
    ///         실제 Firestore 문서 ID를 사용하여 데이터 일관성 보장
    public init(
        id: String = UUID().uuidString,
        templateId: String? = nil,
        title: String,
        description: String? = nil,
        category: QuestCategory,
        status: QuestStatus = .pending,
        recurringType: RecurringType = .none,
        assignedTo: String? = nil,
        createdBy: String,
        familyId: String,
        points: Int = 10,
        dueDate: Date? = nil,
        selectedRepeatDays: [Int]? = nil,
        recurringEndDate: Date? = nil,
        createdAt: Date = Date(),
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        approvedAt: Date? = nil,
        updatedAt: Date = Date(),
        lastNotifiedAt: Date? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.title = title
        self.description = description
        self.category = category
        self.status = status
        self.recurringType = recurringType
        self.assignedTo = assignedTo
        self.createdBy = createdBy
        self.familyId = familyId
        self.points = points
        self.dueDate = dueDate
        self.selectedRepeatDays = selectedRepeatDays
        self.recurringEndDate = recurringEndDate
        self.createdAt = createdAt
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.approvedAt = approvedAt
        self.updatedAt = updatedAt
        self.lastNotifiedAt = lastNotifiedAt
    }
}

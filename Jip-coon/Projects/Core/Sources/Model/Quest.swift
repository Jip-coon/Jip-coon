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
/// - 반복 퀘스트 기능 지원
/// - 다양한 계산 속성을 통한 상태 및 날짜 정보 제공
public struct Quest: Codable, Identifiable {
    // MARK: - 기본 식별 정보
    public let id: String              // Firestore 문서 ID (고유 식별자)
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
    public var recurringEndDate: Date? // 반복 퀘스트 종료일

    // MARK: - 타임스탬프 정보
    public let createdAt: Date         // 퀘스트 생성 시각
    public var updatedAt: Date         // 마지막 수정 시각
    public var startedAt: Date?        // 퀘스트 시작 시각
    public var completedAt: Date?      // 퀘스트 완료 시각
    public var approvedAt: Date?       // 퀘스트 승인 시각
    
    /// 기본 퀘스트 생성자
    /// - Parameters:
    ///   - title: 퀘스트 제목
    ///   - description: 퀘스트 상세 설명 (선택사항)
    ///   - category: 퀘스트 카테고리
    ///   - createdBy: 생성자 사용자 ID
    ///   - familyId: 소속 가족 ID
    ///   - points: 완료 시 획득 포인트 (기본값: 10)
    /// - Note: UUID를 사용하여 클라이언트 측 임시 ID 생성
    ///         실제 저장 시 Firestore 자동 ID로 교체
    public init(
        title: String,
        description: String? = nil,
        category: QuestCategory,
        createdBy: String,
        familyId: String,
        points: Int = 10
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.category = category
        self.status = .pending
        self.assignedTo = nil
        self.createdBy = createdBy
        self.familyId = familyId
        self.points = points
        self.dueDate = nil
        self.recurringType = .none
        self.recurringEndDate = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.startedAt = nil
        self.completedAt = nil
        self.approvedAt = nil
    }

    /// Firestore 문서 ID를 직접 지정하는 생성자
    /// - Parameters:
    ///   - id: Firestore에서 자동 생성된 문서 ID
    ///   - title: 퀘스트 제목
    ///   - description: 퀘스트 상세 설명 (선택사항)
    ///   - category: 퀘스트 카테고리
    ///   - createdBy: 생성자 사용자 ID
    ///   - familyId: 소속 가족 ID
    ///   - points: 완료 시 획득 포인트 (기본값: 10)
    ///   - assignedTo: 담당자 사용자 ID
    ///   - dueDate: 마감일(날짜, 시간)
    /// - Note: FirebaseQuestService에서 퀘스트 생성 시 사용
    ///         실제 Firestore 문서 ID를 사용하여 데이터 일관성 보장
    public init(
        id: String,
        title: String,
        description: String? = nil,
        category: QuestCategory,
        createdBy: String,
        familyId: String,
        points: Int,
        assignedTo: String? = nil,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.status = .pending
        self.assignedTo = assignedTo
        self.createdBy = createdBy
        self.familyId = familyId
        self.points = points
        self.dueDate = dueDate
        self.recurringType = .none
        self.recurringEndDate = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.startedAt = nil
        self.completedAt = nil
        self.approvedAt = nil
    }

    /// 반복 퀘스트 생성용 생성자 (생성 시각 지정 가능)
    /// - Parameters:
    ///   - id: Firestore 문서 ID
    ///   - title: 퀘스트 제목
    ///   - description: 퀘스트 상세 설명 (선택사항)
    ///   - category: 퀘스트 카테고리
    ///   - createdBy: 생성자 사용자 ID
    ///   - familyId: 소속 가족 ID
    ///   - points: 완료 시 획득 포인트 (기본값: 10)
    ///   - createdAt: 퀘스트 생성 시각 (반복 퀘스트의 경우 원본 생성 시각 유지)
    /// - Note: 반복 퀘스트 생성 시 원본 퀘스트의 생성 시각을 유지하기 위해 사용
    ///         FirebaseQuestService.createRecurringQuest에서 활용
    public init(id: String, title: String, description: String? = nil, category: QuestCategory,
                createdBy: String, familyId: String, points: Int = 10, createdAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.status = .pending
        self.assignedTo = nil
        self.createdBy = createdBy
        self.familyId = familyId
        self.points = points
        self.dueDate = nil
        self.recurringType = .none
        self.recurringEndDate = nil
        self.createdAt = createdAt
        self.updatedAt = Date()
        self.startedAt = nil
        self.completedAt = nil
        self.approvedAt = nil
    }
}

// MARK: - 퀘스트 상태 관련 계산 속성

public extension Quest {
    /// 퀘스트가 특정 담당자에게 할당되었는지 확인
    var isAssigned: Bool {
        return assignedTo != nil
    }

    /// 퀘스트가 현재 진행 중인지 확인 (담당자가 작업을 시작한 상태)
    var isInProgress: Bool {
        return status == .inProgress
    }

    /// 퀘스트가 완료되었는지 확인 (완료 또는 승인 상태 모두 포함)
    var isCompleted: Bool {
        return status == .completed || status == .approved
    }

    /// 퀘스트가 부모/관리자에 의해 승인되었는지 확인
    var isApproved: Bool {
        return status == .approved
    }

    /// 퀘스트 완료가 거절되었는지 확인
    var isRejected: Bool {
        return status == .rejected
    }
    
    /// 퀘스트가 반복 실행되는지 확인
    var isRecurring: Bool {
        return recurringType != .none
    }

    /// 마감 기한이 설정되어 있는지 확인
    var hasDueDate: Bool {
        return dueDate != nil
    }

    /// 마감 기한이 지났는지 확인 (완료되지 않은 경우에만)
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return Date() > dueDate && !isCompleted
    }

    /// 마감 기한이 오늘인지 확인
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    /// 마감 기한이 내일인지 확인
    var isDueTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }
    
    /// 특정 사용자가 담당자인지 확인
    func isAssignedTo(_ userId: String) -> Bool {
        return assignedTo == userId
    }
    
    /// 특정 사용자가 생성자인지 확인
    func isCreatedBy(_ userId: String) -> Bool {
        return createdBy == userId
    }
    
    /// 퀘스트를 진행 상태로 변경
    /// - Parameter userId: 퀘스트를 시작하는 사용자 ID
    /// - Note: 담당자가 맞고 대기 상태인 경우에만 시작 가능
    ///         시작 시각과 수정 시각을 현재 시간으로 기록
    mutating func start(by userId: String) {
        guard assignedTo == userId, status == .pending else { return }
        status = .inProgress
        startedAt = Date()
        updatedAt = Date()
    }

    /// 퀘스트를 완료 상태로 변경
    /// - Note: 진행 중인 퀘스트만 완료 가능
    ///         완료 시각과 수정 시각을 현재 시간으로 기록
    mutating func complete() {
        guard status == .inProgress else { return }
        status = .completed
        completedAt = Date()
        updatedAt = Date()
    }

    /// 퀘스트를 승인 상태로 변경 (관리자 권한)
    /// - Note: 완료된 퀘스트만 승인 가능
    ///         승인 시각과 수정 시각을 현재 시간으로 기록
    mutating func approve() {
        guard status == .completed else { return }
        status = .approved
        approvedAt = Date()
        updatedAt = Date()
    }

    /// 퀘스트 완료를 거절 상태로 변경 (관리자 권한)
    /// - Note: 완료된 퀘스트만 거절 가능
    ///         수정 시각을 현재 시간으로 기록
    mutating func reject() {
        guard status == .completed else { return }
        status = .rejected
        updatedAt = Date()
    }
    
    /// 담당자 지정
    mutating func assign(to userId: String) {
        assignedTo = userId
        updatedAt = Date()
    }
    
    /// 마감 기한까지 남은 시간을 읽기 쉽게 포맷한 문자열
    /// - Returns: "3일 남음", "5시간 남음", "곧 마감", "마감됨" 등의 문자열
    /// - Note: 마감 기한이 없는 경우 nil 반환
    ///         경과 시간에 따라 일/시간/분 단위로 표시
    var timeUntilDueString: String? {
        guard let dueDate = dueDate else { return nil }

        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)

        if timeInterval < 0 {
            return "마감됨"
        }

        let days = Int(timeInterval / 86400)
        let hours = Int(
            (timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600
        )

        if days > 0 {
            return "\(days)일 남음"
        } else if hours > 0 {
            return "\(hours)시간 남음"
        } else {
            return "곧 마감"
        }
    }

    /// 퀘스트 진행 시간을 읽기 쉽게 포맷한 문자열
    /// - Returns: "2시간 30분", "45분" 등의 문자열
    /// - Note: 시작되지 않은 퀘스트는 nil 반환
    ///         완료된 경우 완료 시각까지, 진행 중인 경우 현재까지의 시간 계산
    var progressTimeString: String? {
        guard let startedAt = startedAt else { return nil }

        let now = completedAt ?? Date()
        let timeInterval = now.timeIntervalSince(startedAt)

        let hours = Int(timeInterval / 3600)
        let minutes = Int(
            (timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        )

        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}

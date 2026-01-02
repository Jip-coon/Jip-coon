//
//  Quest.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - 퀘스트 모델

public struct Quest: Codable, Identifiable {
    public let id: String              // 퀘스트 고유 ID
    public var title: String           // 제목
    public var description: String?    // 설명
    public var category: QuestCategory // 카테고리
    public var status: QuestStatus     // 상태
    public var assignedTo: String?     // 담당자 ID
    public let createdBy: String       // 생성자 ID
    public let familyId: String        // 소속 가족 ID
    public var points: Int             // 완료 시 획득 포인트
    public var dueDate: Date?          // 마감일
    public var recurringType: RecurringType // 반복 타입
    public var recurringEndDate: Date? // 반복 종료일
    public let createdAt: Date         // 생성일
    public var updatedAt: Date         // 수정일
    public var startedAt: Date?        // 시작일
    public var completedAt: Date?      // 완료일
    public var approvedAt: Date?       // 승인일
    
    public init(title: String, description: String? = nil, category: QuestCategory,
                createdBy: String, familyId: String, points: Int = 10) {
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

    /// Firebase document ID를 사용하는 생성자
    public init(id: String, title: String, description: String? = nil, category: QuestCategory,
                createdBy: String, familyId: String, points: Int = 10) {
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
        self.createdAt = Date()
        self.updatedAt = Date()
        self.startedAt = nil
        self.completedAt = nil
        self.approvedAt = nil
    }

    /// 반복 퀘스트용 생성자 (createdAt 지정 가능)
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

// MARK: - 퀘스트 Extensions

public extension Quest {
    /// 퀘스트가 할당되었는지 확인
    var isAssigned: Bool {
        return assignedTo != nil
    }
    
    /// 퀘스트가 진행 중인지 확인
    var isInProgress: Bool {
        return status == .inProgress
    }
    
    /// 퀘스트가 완료되었는지 확인
    var isCompleted: Bool {
        return status == .completed || status == .approved
    }
    
    /// 퀘스트가 승인되었는지 확인
    var isApproved: Bool {
        return status == .approved
    }
    
    /// 퀘스트가 거절되었는지 확인
    var isRejected: Bool {
        return status == .rejected
    }
    
    /// 퀘스트가 반복 퀘스트인지 확인
    var isRecurring: Bool {
        return recurringType != .none
    }
    
    /// 마감일이 있는지 확인
    var hasDueDate: Bool {
        return dueDate != nil
    }
    
    /// 마감일이 지났는지 확인
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return Date() > dueDate && !isCompleted
    }
    
    /// 오늘이 마감일인지 확인
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    /// 내일이 마감일인지 확인
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
    
    /// 퀘스트 시작
    mutating func start(by userId: String) {
        guard assignedTo == userId, status == .pending else { return }
        status = .inProgress
        startedAt = Date()
        updatedAt = Date()
    }
    
    /// 퀘스트 완료
    mutating func complete() {
        guard status == .inProgress else { return }
        status = .completed
        completedAt = Date()
        updatedAt = Date()
    }
    
    /// 퀘스트 승인
    mutating func approve() {
        guard status == .completed else { return }
        status = .approved
        approvedAt = Date()
        updatedAt = Date()
    }
    
    /// 퀘스트 거절
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
    
    /// 마감일까지 남은 시간 문자열
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
    
    /// 진행 시간 문자열
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

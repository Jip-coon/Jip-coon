//
//  QusetTemplate.swift
//  Core
//
//  Created by 예슬 on 1/22/26.
//

import Foundation

/// 반복 퀘스트 모델
/// - 반복 퀘스트인 경우 QuestTemplate에 저장
/// - 실제 인스턴스가 필요할 경우(퀘스트 완료 했을 때) Quest 문서를 Firestore에 생성
/// - 동적 생성: 뷰에서 보여줄 때만 Template을 읽어서 "가짜 퀘스트"를 리스트에 섞어줍니다.
public struct QuestTemplate: Codable, Identifiable {
    public let id: String
    public var title: String
    public var description: String?
    public var category: QuestCategory
    public var points: Int
    public let createdBy: String
    public let familyId: String
    public var assignedTo: String?
    
    public var recurringType: RecurringType
    public var selectedRepeatDays: [Int] // 0(일) ~ 6(토)
    public var startDate: Date
    public var recurringEndDate: Date?
    public var updatedAt: Date
    public var excludedDates: [Date]?
    
    /// Quest Template 생성자
    /// - Parameters:
    ///   - id: Template ID
    ///   - title: 퀘스트 제목
    ///   - description: 퀘스트 상세 설명 (선택사항)
    ///   - category: 퀘스트 카테고리
    ///   - points: 완료 시 획득 포인트 (기본값: 10)
    ///   - createdBy: 퀘스트 생성 시각
    ///   - familyId: 소속 가족 ID
    ///   - assignedTo: 담당자 사용자 ID
    ///   - recurringType: 퀘스트 반복 유형
    ///   - selectedRepeatDays: 선택된 퀘스트 반복 요일
    ///   - startDate: 퀘스트 시작일
    ///   - recurringEndDate: 반복 퀘스트 종료일
    ///   - updatedAt: 마지막 수정 시각
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String? = nil,
        category: QuestCategory,
        points: Int,
        createdBy: String,
        familyId: String,
        assignedTo: String? = nil,
        recurringType: RecurringType,
        selectedRepeatDays: [Int],
        startDate: Date,
        recurringEndDate: Date? = nil,
        updatedAt: Date = Date(),
        excludedDates: [Date]?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.points = points
        self.createdBy = createdBy
        self.familyId = familyId
        self.assignedTo = assignedTo
        self.recurringType = recurringType
        self.selectedRepeatDays = selectedRepeatDays
        self.startDate = startDate
        self.recurringEndDate = recurringEndDate
        self.updatedAt = updatedAt
        self.excludedDates = excludedDates
    }
}

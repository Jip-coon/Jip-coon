//
//  Enums.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - 사용자 역할

public enum UserRole: String, CaseIterable, Codable {
    case parent = "parent"      // 부모
    case child = "child"        // 자녀
    
    public var displayName: String {
        switch self {
        case .parent: return "부모"
        case .child: return "자녀"
        }
    }
}

// MARK: - 퀘스트 상태

public enum QuestStatus: String, CaseIterable, Codable {
    case pending = "pending"        // 대기중
    case inProgress = "in_progress" // 진행중
    case completed = "completed"    // 완료됨 (승인 대기)
    case approved = "approved"      // 승인됨
    case rejected = "rejected"      // 거절됨
    
    public var displayName: String {
        switch self {
        case .pending: return "대기중"
        case .inProgress: return "진행중"
        case .completed: return "완료됨"
        case .approved: return "승인됨"
        case .rejected: return "거절됨"
        }
    }
    
    public var color: String {
        switch self {
        case .pending: return "textGray"
        case .inProgress: return "mainOrange"
        case .completed: return "secondaryOrange"
        case .approved: return "green"
        case .rejected: return "textRed"
        }
    }
}

// MARK: - 퀘스트 카테고리

public enum QuestCategory: String, CaseIterable, Codable {
    case cleaning = "cleaning"      // 청소
    case cooking = "cooking"        // 요리
    case laundry = "laundry"        // 빨래
    case dishes = "dishes"          // 설거지
    case trash = "trash"            // 쓰레기
    case pet = "pet"                // 반려동물
    case study = "study"            // 공부
    case exercise = "exercise"      // 운동
    case other = "other"            // 기타
    
    public var displayName: String {
        switch self {
        case .cleaning: return "청소"
        case .cooking: return "요리"
        case .laundry: return "빨래"
        case .dishes: return "설거지"
        case .trash: return "쓰레기"
        case .pet: return "반려동물"
        case .study: return "공부"
        case .exercise: return "운동"
        case .other: return "기타"
        }
    }
    
    public var emoji: String {
        switch self {
        case .cleaning: return "🧹"
        case .cooking: return "👨‍🍳"
        case .laundry: return "👕"
        case .dishes: return "🍽️"
        case .trash: return "🗑️"
        case .pet: return "🐕"
        case .study: return "📚"
        case .exercise: return "💪"
        case .other: return "📝"
        }
    }
    
    public var backgroundColor: String {
        switch self {
        case .cleaning: return "blue1"
        case .cooking: return "orange3"
        case .laundry: return "purple1"
        case .dishes: return "green1"
        case .trash: return "textFieldStroke"
        case .pet: return "brown1"
        case .study: return "red1"
        case .exercise: return "yellow1"
        case .other: return "blue2"
        }
    }
}

// MARK: - 반복 타입

public enum RecurringType: String, CaseIterable, Codable {
    case none = "none"          // 반복 없음
    case daily = "daily"        // 매일
    case weekly = "weekly"      // 매주
    case monthly = "monthly"    // 매월
    
    public var displayName: String {
        switch self {
        case .none: return "반복 없음"
        case .daily: return "매일"
        case .weekly: return "매주"
        case .monthly: return "매월"
        }
    }
    
    public var shortDisplayName: String {
        switch self {
        case .none: return "없음"
        case .daily: return "매일"
        case .weekly: return "매주"
        case .monthly: return "매월"
        }
    }
}

// MARK: - 긴급도 레벨

public enum UrgencyLevel: String, CaseIterable, Codable {
    case low = "low"  // 낮음
    case medium = "medium"  // 보통
    case high = "high"  // 높음
    case critical = "critical"  // 매우 긴급

    public var displayName: String {
        switch self {
        case .low: return "여유"
        case .medium: return "보통"
        case .high: return "긴급"
        case .critical: return "기한 지남"
        }
    }

    public var color: String {
        switch self {
        case .low: return "textGray"
        case .medium: return "mainOrange"
        case .high: return "secondaryOrange"
        case .critical: return "textRed"
        }
    }

    public var emoji: String {
        switch self {
        case .low: return "📅"
        case .medium: return "⏰"
        case .high: return "⚠️"
        case .critical: return "🚨"
        }
    }
    
}

// MARK: - 반복 퀘스트 삭제

public enum DeleteMode {
    case single    // 이 일정만 삭제
    case all       // 전체 반복 삭제
}

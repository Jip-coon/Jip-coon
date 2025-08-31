//
//  QuestSubmission.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - 퀘스트 제출 모델

public struct QuestSubmission: Codable, Identifiable {
    public let id: String              // 제출 고유 ID
    public let questId: String         // 퀘스트 ID
    public let userId: String          // 제출자 ID
    public var comment: String?        // 완료 코멘트
    public var imageURLs: [String]     // 첨부 이미지 URL 목록
    public let submittedAt: Date       // 제출일
    public var reviewedBy: String?     // 검토자 ID
    public var reviewedAt: Date?       // 검토일
    public var reviewComment: String?  // 검토 코멘트
    public var isApproved: Bool?       // 승인 여부
    
    public init(questId: String, userId: String, comment: String? = nil, imageURLs: [String] = []) {
        self.id = UUID().uuidString
        self.questId = questId
        self.userId = userId
        self.comment = comment
        self.imageURLs = imageURLs
        self.submittedAt = Date()
        self.reviewedBy = nil
        self.reviewedAt = nil
        self.reviewComment = nil
        self.isApproved = nil
    }
}

// MARK: - 퀘스트 제출 Extensions

public extension QuestSubmission {
    /// 제출이 검토되었는지 확인
    var isReviewed: Bool {
        return reviewedBy != nil && reviewedAt != nil
    }
    
    /// 제출이 승인되었는지 확인
    var isApprovedSubmission: Bool {
        return isApproved == true
    }
    
    /// 제출이 거절되었는지 확인
    var isRejected: Bool {
        return isApproved == false
    }
    
    /// 제출이 승인 대기 중인지 확인
    var isPending: Bool {
        return isApproved == nil
    }
    
    /// 이미지가 첨부되었는지 확인
    var hasImages: Bool {
        return !imageURLs.isEmpty
    }
    
    /// 첨부된 이미지 개수
    var imageCount: Int {
        return imageURLs.count
    }
    
    /// 코멘트가 있는지 확인
    var hasComment: Bool {
        return comment != nil && !comment!.isEmpty
    }
    
    /// 검토 코멘트가 있는지 확인
    var hasReviewComment: Bool {
        return reviewComment != nil && !reviewComment!.isEmpty
    }
    
    /// 특정 사용자가 제출자인지 확인
    func isSubmittedBy(_ userId: String) -> Bool {
        return self.userId == userId
    }
    
    /// 특정 사용자가 검토자인지 확인
    func isReviewedBy(_ userId: String) -> Bool {
        return reviewedBy == userId
    }
    
    /// 제출 승인
    mutating func approve(by reviewerId: String, comment: String? = nil) {
        isApproved = true
        reviewedBy = reviewerId
        reviewedAt = Date()
        reviewComment = comment
    }
    
    /// 제출 거절
    mutating func reject(by reviewerId: String, comment: String? = nil) {
        isApproved = false
        reviewedBy = reviewerId
        reviewedAt = Date()
        reviewComment = comment
    }
    
    /// 제출 상태 문자열
    var statusDisplayName: String {
        if isPending {
            return "검토 대기"
        } else if isApprovedSubmission {
            return "승인됨"
        } else {
            return "거절됨"
        }
    }
    
    /// 제출 상태 색상
    var statusColor: String {
        if isPending {
            return "secondaryOrange"
        } else if isApprovedSubmission {
            return "green"
        } else {
            return "textRed"
        }
    }
    
    /// 제출 후 경과 시간 문자열
    var timeAgoString: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(submittedAt)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)일 전"
        } else if hours > 0 {
            return "\(hours)시간 전"
        } else if minutes > 0 {
            return "\(minutes)분 전"
        } else {
            return "방금 전"
        }
    }
    
    /// 검토 후 경과 시간 문자열
    var reviewTimeAgoString: String? {
        guard let reviewedAt = reviewedAt else { return nil }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(reviewedAt)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)일 전 검토"
        } else if hours > 0 {
            return "\(hours)시간 전 검토"
        } else if minutes > 0 {
            return "\(minutes)분 전 검토"
        } else {
            return "방금 검토"
        }
    }
}

// MARK: - 퀘스트 제출 통계

public struct SubmissionStatistics: Codable {
    public let userId: String
    public let totalSubmissions: Int
    public let approvedSubmissions: Int
    public let rejectedSubmissions: Int
    public let pendingSubmissions: Int
    public let averageReviewTime: TimeInterval // 평균 검토 시간 (초)
    public let updatedAt: Date
    
    public init(userId: String, totalSubmissions: Int = 0, approvedSubmissions: Int = 0,
                rejectedSubmissions: Int = 0, pendingSubmissions: Int = 0,
                averageReviewTime: TimeInterval = 0) {
        self.userId = userId
        self.totalSubmissions = totalSubmissions
        self.approvedSubmissions = approvedSubmissions
        self.rejectedSubmissions = rejectedSubmissions
        self.pendingSubmissions = pendingSubmissions
        self.averageReviewTime = averageReviewTime
        self.updatedAt = Date()
    }
}

public extension SubmissionStatistics {
    /// 승인율
    var approvalRate: Double {
        let reviewedSubmissions = approvedSubmissions + rejectedSubmissions
        return reviewedSubmissions > 0 ? Double(approvedSubmissions) / Double(reviewedSubmissions) : 0.0
    }
    
    /// 승인율 백분율 문자열
    var approvalRatePercentage: String {
        return String(format: "%.1f%%", approvalRate * 100)
    }
    
    /// 평균 검토 시간 문자열
    var averageReviewTimeString: String {
        let hours = Int(averageReviewTime / 3600)
        let minutes = Int((averageReviewTime.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}

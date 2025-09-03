//
//  FirestoreStructure.swift
//  Core
//
//  Created by 심관혁 on 1/28/25.
//

import Foundation

// MARK: - Firestore 컬렉션 이름

struct FirestoreCollections {
    static let users = "users"
    static let families = "families"
    static let quests = "quests"
    static let questSubmissions = "quest_submissions"
    static let statistics = "statistics"
    static let notifications = "notifications"
}


// MARK: - Firestore 필드 이름

struct FirestoreFields {
    
    struct User {
        static let id = "id"
        static let name = "name"
        static let email = "email"
        static let role = "role"
        static let familyId = "familyId"
        static let profileImageURL = "profileImageURL"
        static let points = "points"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    struct Family {
        static let id = "id"
        static let name = "name"
        static let inviteCode = "inviteCode"
        static let memberIds = "memberIds"
        static let createdBy = "createdBy"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    struct Quest {
        static let id = "id"
        static let title = "title"
        static let description = "description"
        static let category = "category"
        static let status = "status"
        static let assignedTo = "assignedTo"
        static let createdBy = "createdBy"
        static let familyId = "familyId"
        static let points = "points"
        static let dueDate = "dueDate"
        static let recurringType = "recurringType"
        static let recurringEndDate = "recurringEndDate"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let startedAt = "startedAt"
        static let completedAt = "completedAt"
        static let approvedAt = "approvedAt"
    }
    
    struct QuestSubmission {
        static let id = "id"
        static let questId = "questId"
        static let userId = "userId"
        static let comment = "comment"
        static let imageURLs = "imageURLs"
        static let submittedAt = "submittedAt"
        static let reviewedBy = "reviewedBy"
        static let reviewedAt = "reviewedAt"
        static let reviewComment = "reviewComment"
        static let isApproved = "isApproved"
    }
}

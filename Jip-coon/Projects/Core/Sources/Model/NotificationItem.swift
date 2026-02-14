//
//  NotificationItem.swift
//  Core
//
//  Created by 예슬 on 2/10/26.
//

import Foundation

/// 알림
/// - id: 알림 ID
/// - questId: 퀘스트 ID
/// - templateId: 템플릿 ID
/// - title: 알림 제목
/// - body: 알림 내용
/// - type: 알림 종류
/// - category: 퀘스트 카테고리
/// - isRead: 알림 읽음 확인
/// - createdAt: 알림 생성 시각
public struct NotificationItem: Codable, Identifiable {
    public let id: String
    public let questId: String?
    public let templateId: String?
    public var title: String
    public var body: String
    public var type: NotificationSettingType
    public var category: QuestCategory?
    public var isRead: Bool
    public let createdAt: Date
    
    public init(
        id: String,
        questId: String? = nil,
        templateId: String? = nil,
        title: String,
        body: String,
        type: NotificationSettingType,
        category: QuestCategory? = nil,
        isRead: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.questId = questId
        self.templateId = templateId
        self.title = title
        self.body = body
        self.type = type
        self.category = category
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

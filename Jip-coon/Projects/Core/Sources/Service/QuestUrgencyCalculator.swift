//
//  QuestUrgencyCalculator.swift
//  Core
//
//  Created by 심관혁 on 9/18/25.
//

import Foundation

// MARK: - 퀘스트 긴급도 계산 유틸리티

public struct QuestUrgencyCalculator {

    /// 퀘스트의 긴급도 레벨을 계산합니다
    /// - Parameter quest: 긴급도를 계산할 퀘스트
    /// - Returns: 계산된 긴급도 레벨
    public static func determineUrgencyLevel(for quest: Quest) -> UrgencyLevel {
        guard let dueDate = quest.dueDate else { return .medium }

        let timeRemaining = dueDate.timeIntervalSinceNow
        let hoursRemaining = timeRemaining / 3600

        if quest.isOverdue {
            return .critical
        } else if hoursRemaining <= 2 {
            return .high
        } else if hoursRemaining <= 6 {
            return .medium
        } else {
            return .low
        }
    }

    /// 긴급도에 따른 메시지를 생성합니다
    /// - Parameters:
    ///   - quest: 대상 퀘스트
    ///   - urgencyLevel: 긴급도 레벨
    /// - Returns: 긴급도에 맞는 메시지
    public static func getUrgentTaskMessage(for quest: Quest, urgencyLevel: UrgencyLevel) -> String {
        var message = quest.description ?? ""

        switch urgencyLevel {
        case .critical:
            message += "\n\n🚨 이미 마감시간이 지났습니다!"
        case .high:
            message += "\n\n⚠️ 곧 마감됩니다!"
        case .medium:
            message += "\n\n⏰ 마감시간이 얼마 남지 않았습니다."
        case .low:
            message += "\n\n📅 여유가 있지만 미리 준비하세요."
        }

        return message
    }

    /// 긴급 퀘스트 목록을 마감시간 순으로 정렬합니다
    /// - Parameter quests: 정렬할 퀘스트 배열
    /// - Returns: 마감시간 순으로 정렬된 퀘스트 배열
    public static func sortQuestsByUrgency(_ quests: [Quest]) -> [Quest] {
        return quests.sorted { quest1, quest2 in
            guard let date1 = quest1.dueDate, let date2 = quest2.dueDate else { return false }
            return date1 < date2
        }
    }
}


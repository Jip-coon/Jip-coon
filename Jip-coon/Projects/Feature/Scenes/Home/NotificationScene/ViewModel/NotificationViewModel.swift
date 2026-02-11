//
//  NotificationViewModel.swift
//  Feature
//
//  Created by 예슬 on 2/11/26.
//

import Core
import Foundation

final class NotificationViewModel {

}

// MARK: - Section

enum NotificationSection: Int, CaseIterable {
    case today
    case recent
    
    var title: String {
        switch self {
            case .today: return "오늘"
            case .recent: return "최근"
        }
    }
}

struct NotificationSectionModel {
    let section: NotificationSection
    var items: [NotificationItem]
}

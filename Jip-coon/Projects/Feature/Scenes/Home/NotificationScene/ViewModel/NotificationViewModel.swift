//
//  NotificationViewModel.swift
//  Feature
//
//  Created by 예슬 on 2/11/26.
//

import Core
import Foundation

final class NotificationViewModel: ObservableObject {
    
    @Published private(set) var sections: [NotificationSectionModel] = []
    
    private let userService: UserServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    init(
        userService: UserServiceProtocol,
        notificationService: NotificationServiceProtocol = FirebaseNotificationService()
    ) {
        self.userService = userService
        self.notificationService = notificationService
        
        fetchNotifications()
    }
    
    private func fetchNotifications() {
        Task {
            guard let user = try await userService.getCurrentUser() else {
                print("알림 화면: 현재 사용자 정보를 가져오지 못했습니다.")
                return
            }
            
            do {
                let notificationItems = try await notificationService.fetchNotifications(userId: user.id)
                await MainActor.run {
                    self.sections = transformToSections(items: notificationItems)
                }
            } catch {
                print("알림을 가져올 수 없습니다: \(error.localizedDescription)")
            }
        }
    }
    
    private func transformToSections(items: [NotificationItem]) -> [NotificationSectionModel] {
        let calendar = Calendar.current
        
        // 오늘 받은 알림
        let todayItems = items.filter { calendar.isDateInToday($0.createdAt) }
        
        // 오늘을 제외한 최근 7일 내 알림 (서버가 7일 뒤 삭제하므로 나머지는 모두 최근)
        let recentItems = items.filter { !calendar.isDateInToday($0.createdAt) }
        
        // 섹션 모델 조립
        return [
            NotificationSectionModel(section: .today, items: todayItems),
            NotificationSectionModel(section: .recent, items: recentItems)
        ].filter { !$0.items.isEmpty }
    }
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

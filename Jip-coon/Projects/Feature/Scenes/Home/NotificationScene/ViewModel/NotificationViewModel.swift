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
    @Published var navigationDestination: NotificationDestination?
    
    private var userId: String?
    
    let userService: UserServiceProtocol
    let questService: QuestServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    init(
        userService: UserServiceProtocol,
        questService: QuestServiceProtocol,
        notificationService: NotificationServiceProtocol = FirebaseNotificationService()
    ) {
        self.userService = userService
        self.questService = questService
        self.notificationService = notificationService
        
        fetchNotifications()
    }
    
    /// 알림 데이터 가져오기
    private func fetchNotifications() {
        Task {
            guard let user = try await userService.getCurrentUser() else {
                print("알림 화면: 현재 사용자 정보를 가져오지 못했습니다.")
                return
            }
            
            do {
                self.userId = user.id
                let notificationItems = try await notificationService.fetchNotifications(userId: user.id)
                
                await MainActor.run {
                    self.sections = transformToSections(items: notificationItems)
                }
            } catch {
                print("알림을 가져올 수 없습니다: \(error.localizedDescription)")
            }
        }
    }
    
    /// 알림을 섹션별로 나누기
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
    
    /// 알림을 눌렀을 때
    func didSelectNotification(at indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        
        // 1. 읽음 처리 (서버 & 로컬)
        markAsRead(item: item, indexPath: indexPath)
        
        // 2. 이동 로직
        Task {
            switch item.type {
                case .deadline, .questAssigned:
                    await handleQuestNavigation(item: item)
                case .dailySummary:
                    await MainActor.run {
                        self.navigationDestination = .myTask
                    }
            }
        }
    }
    
    /// 알림 읽음 처리
    private func markAsRead(item: NotificationItem, indexPath: IndexPath) {
        guard let userId = self.userId else { return }
        sections[indexPath.section].items[indexPath.row].isRead = true
        
        Task {
            try? await notificationService.updateReadStatus(userId: userId, notificationId: item.id)
        }
    }
    
    /// 알림 -> 퀘스트 상세 화면으로 넘어가기
    private func handleQuestNavigation(item: NotificationItem) async {
        do {
            var quest: Quest?
            
            // questId가 있으면 실제 퀘스트
            if let questId = item.questId, !questId.isEmpty, !questId.hasPrefix("virtual_") {
                quest = try await questService.getQuest(by: questId)
            }
            // templateId만 있으면 가상 퀘스트 생성
            else if let templateId = item.templateId, !templateId.isEmpty {
                quest = try await questService.createVirtualQuestFromTemplate(notification: item)
            }
            
            if let finalQuest = quest {
                await MainActor.run {
                    self.navigationDestination = .questDetail(quest: finalQuest)
                }
            } else {
                print("퀘스트를 찾을 수 없습니다.")
            }
        } catch {
            print("퀘스트 로드 실패: \(error)")
        }
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

enum NotificationDestination {
    case questDetail(quest: Quest)
    case myTask
}

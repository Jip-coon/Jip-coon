//
//  ApprovalViewModel.swift
//  Feature
//
//  Created by 심관혁 on 12/31/25.
//

import Core
import Combine
import Foundation

final class ApprovalViewModel: ObservableObject {
    @Published var pendingQuests: [Quest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let questService: QuestServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(questService: QuestServiceProtocol, userService: UserServiceProtocol) {
        self.questService = questService
        self.userService = userService
    }

    // 승인 대기 중인 퀘스트들 로드
    func loadPendingQuests() async {
        isLoading = true
        errorMessage = nil

        do {
            guard let currentUser = try await userService.getCurrentUser(),
                  let familyId = currentUser.familyId else {
                pendingQuests = []
                isLoading = false
                return
            }

            // 상태가 'completed'인 퀘스트들 조회 (승인 대기 중)
            let completedQuests = try await questService.getQuestsByStatus(
                familyId: familyId,
                status: .completed
            )

            // 현재 사용자가 생성자이고, 아직 승인되지 않은 퀘스트들만 필터링
            pendingQuests = completedQuests.filter { quest in
                quest.createdBy == currentUser.id && quest.status == .completed
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            pendingQuests = []
            isLoading = false
        }
    }

    // 퀘스트 승인
    func approveQuest(_ quest: Quest) async {
        do {
            try await questService.reviewQuest(
                questId: quest.id,
                isApproved: true,
                reviewComment: nil,
                reviewerId: (try await userService.getCurrentUser())?.id ?? "",
                userService: userService
            )

            // 로컬에서 제거
            pendingQuests.removeAll { $0.id == quest.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 퀘스트 거절
    func rejectQuest(_ quest: Quest, reason: String?) async {
        do {
            try await questService.reviewQuest(
                questId: quest.id,
                isApproved: false,
                reviewComment: reason,
                reviewerId: (try await userService.getCurrentUser())?.id ?? "",
                userService: userService
            )

            // 로컬에서 제거
            pendingQuests.removeAll { $0.id == quest.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

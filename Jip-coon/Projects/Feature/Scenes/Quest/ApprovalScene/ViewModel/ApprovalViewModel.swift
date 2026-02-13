//
//  ApprovalViewModel.swift
//  Feature
//
//  Created by 심관혁 on 12/31/25.
//

import Core
import Combine
import Foundation

/// 승인 화면의 비즈니스 로직을 담당하는 뷰모델
/// - 승인 대기 중인 퀘스트들의 조회 및 관리
/// - 퀘스트 승인/거절 처리 및 포인트 지급 로직
/// - ObservableObject를 준수하여 Combine 기반 반응형 UI 지원
/// - 부모/관리자가 자녀들의 완료된 작업을 검토하고 보상하는 워크플로우 구현
final class ApprovalViewModel: ObservableObject {
    @Published var pendingQuests: [Quest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let questService: QuestServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    /// 의존성 주입을 통한 뷰모델 초기화
    /// - Parameters:
    ///   - questService: 퀘스트 상태 변경 및 조회를 위한 프로토콜 준수 객체
    ///   - userService: 사용자 정보 및 포인트 관리를 위한 프로토콜 준수 객체
    /// - Note: 서비스들을 외부에서 주입받아 결합도를 낮추고 테스트 용이성을 확보
    init(questService: QuestServiceProtocol, userService: UserServiceProtocol) {
        self.questService = questService
        self.userService = userService
    }

    /// 승인 대기 중인 퀘스트들을 비동기로 로드하는 메소드
    /// - 현재 사용자가 생성자로서 승인해야 할 완료된 퀘스트들을 조회
    /// - 가족 ID를 통해 해당 가족의 완료된 퀘스트들을 필터링
    /// - 현재 사용자가 생성한 퀘스트 중 아직 승인되지 않은 것들만 포함
    /// - Note: Swift Concurrency의 async/await 패턴을 사용하여 비동기 처리
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

            pendingQuests = completedQuests.filter { quest in
                quest.status == .completed
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            pendingQuests = []
            isLoading = false
        }
    }

    /// 퀘스트를 승인하고 포인트를 지급하는 메소드
    /// - Parameter quest: 승인할 퀘스트 객체
    /// - Note: questService의 reviewQuest를 호출하여 승인 처리
    ///         포인트 지급은 userService를 통해 자동으로 수행됨
    ///         승인 완료 후 로컬 목록에서 제거하여 UI 즉시 업데이트
    func approveQuest(_ quest: Quest) async {
        do {
            try await questService.reviewQuest(
                questId: quest.id,
                isApproved: true,
                reviewerId: (try await userService.getCurrentUser())?.id ?? "",
                userService: userService
            )
            
            // 로컬에서 제거
            await MainActor.run {
                self.pendingQuests.removeAll { $0.id == quest.id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// 퀘스트를 거절하는 메소드
    /// - Parameters:
    ///   - quest: 거절할 퀘스트 객체
    ///   - reason: 거절 사유 (선택사항)
    /// - Note: questService의 reviewQuest를 호출하여 거절 처리
    ///         선택적으로 거절 사유를 저장할 수 있음
    ///         거절 완료 후 로컬 목록에서 제거하여 UI 즉시 업데이트
    /// 퀘스트를 거절하는 메소드
    /// - Parameters:
    ///   - quest: 거절할 퀘스트 객체
    /// - Note: questService의 reviewQuest를 호출하여 거절 처리
    ///         거절 완료 후 로컬 목록에서 제거하여 UI 즉시 업데이트
    func rejectQuest(_ quest: Quest) async {
        do {
            try await questService.reviewQuest(
                questId: quest.id,
                isApproved: false,
                reviewerId: (try await userService.getCurrentUser())?.id ?? "",
                userService: userService
            )
            
            // 로컬에서 제거
            await MainActor.run {
                self.pendingQuests.removeAll { $0.id == quest.id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

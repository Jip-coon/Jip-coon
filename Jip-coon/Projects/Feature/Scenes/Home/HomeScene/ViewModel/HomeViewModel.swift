//
//  HomeViewModel.swift
//  Feature
//
//  Created by 심관혁 on 1/27/26.
//

import Foundation
import Combine
import Core

public final class HomeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var family: Family?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isParent: Bool = false // 부모 여부
    @Published var selectedFilter: HomeFilterType = .myTask
    
    // MARK: - Services
    public let userService: UserServiceProtocol
    public let familyService: FamilyServiceProtocol
    public let questService: QuestServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var questSubscription: AnyCancellable?
    
    // MARK: - Initializer
    
    public init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.userService = userService
        self.familyService = familyService
        self.questService = questService
        
        loadFamilyInfo()
        setupRealtimeQuestObservation()
    }
    
    // MARK: - Data Loading
    
    /// 가족 정보 로드
    func loadFamilyInfo() {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                guard let currentUser = try await userService.getCurrentUser() else {
                    await MainActor.run {
                        self.family = nil
                        self.isLoading = false
                    }
                    return
                }
                
                guard let familyId = currentUser.familyId else {
                    await MainActor.run {
                        self.family = nil
                        self.isLoading = false
                    }
                    return
                }
                
                let family = try await familyService.getFamily(by: familyId)
                
                await MainActor.run {
                    self.family = family
                    self.isParent = currentUser.role == .parent
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.family = nil
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - User Actions
    
    func selectFilter(_ filter: HomeFilterType) {
        selectedFilter = filter
    }
    
    // MARK: - Realtime Updates
    
    /// 실시간 퀘스트 관찰 설정
    private func setupRealtimeQuestObservation() {
        Task {
            do {
                if let currentUser = try await userService.getCurrentUser(),
                   let familyId = currentUser.familyId {
                    await startRealtimeObservation(familyId: familyId)
                }
            } catch {
                // 실시간 관찰 설정 실패
            }
        }
    }
    
    /// 실시간 관찰 시작
    private func startRealtimeObservation(familyId: String) async {
        await MainActor.run {
            questSubscription?.cancel()
        }
        
        questSubscription = questService
            .observeFamilyQuests(familyId: familyId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    // 실시간 관찰 에러
                }
            } receiveValue: { [weak self] quests in
                self?.notifyQuestUpdate()
            }
    }
    
    /// 퀘스트 업데이트 알림 전송
    private func notifyQuestUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name("QuestCreated"), object: nil)
    }
    
    // MARK: - Presenter Helpers
    
    /// 가족 정보 팝업을 위한 데이터 반환
    func getFamilyInfoAlertContents() -> (title: String, message: String, inviteCode: String)? {
        guard let family = family else { return nil }
        return (
            title: "가족 정보",
            message: "가족명: \(family.name)\n초대코드: \(family.inviteCode)",
            inviteCode: family.inviteCode
        )
    }
}

//
//  RankingViewModel.swift
//  Feature
//
//  Created by 심관혁 on 1/2/26.
//

import Core
import Combine
import Foundation

public final class RankingViewModel: ObservableObject {
    @Published var familyMembers: [User] = []
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol

    init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol
    ) {
        self.userService = userService
        self.familyService = familyService
    }

    /// 가족 구성원 랭킹 데이터 로드
    func loadRankingData() async {
        isLoading = true
        errorMessage = nil

        do {
            // 현재 사용자 정보 가져오기
            guard let currentUser = try await userService.getCurrentUser() else {
                errorMessage = "사용자 정보를 찾을 수 없습니다."
                isLoading = false
                return
            }

            self.currentUser = currentUser

            // 가족 ID 확인 및 필요시 동기화
            var familyId = currentUser.familyId
            if familyId == nil {
                do {
                    try await userService.syncCurrentUserDocument()
                    // 동기화 후 다시 사용자 정보 조회
                    if let updatedUser = try await userService.getCurrentUser() {
                        self.currentUser = updatedUser
                        familyId = updatedUser.familyId
                    }
                } catch {
                    errorMessage = "가족 정보 동기화에 실패했습니다."
                    isLoading = false
                    return
                }
            }

            guard let finalFamilyId = familyId else {
                errorMessage = "가족에 속해있지 않습니다."
                isLoading = false
                return
            }

            // 가족 구성원 목록 가져오기
            let members = try await userService.getFamilyMembers(
                familyId: finalFamilyId
            )

            // 포인트 기준으로 내림차순 정렬 (포인트가 높은 순)
            let sortedMembers = members.sorted { $0.points > $1.points }

            await MainActor.run {
                self.familyMembers = sortedMembers
                self.isLoading = false
            }

        } catch {
            await MainActor.run {
                self.errorMessage = "랭킹 데이터를 불러오는데 실패했습니다."
                self.isLoading = false
            }
        }
    }

    /// 현재 사용자의 랭킹 위치 계산
    var currentUserRank: Int? {
        guard let currentUser = currentUser else { return nil }
        return familyMembers
            .firstIndex(where: { $0.id == currentUser.id })?
            .advanced(by: 1)
    }

    /// 랭킹 데이터 새로고침
    func refreshData() {
        Task {
            await loadRankingData()
        }
    }
}

// MARK: - 랭킹 관련 Extensions

extension User {
    /// 랭킹 표시를 위한 포맷된 포인트 문자열
    var formattedPoints: String {
        return "\(points)P"
    }

    /// 순위 표시를 위한 이모지
    func rankEmoji(rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
}

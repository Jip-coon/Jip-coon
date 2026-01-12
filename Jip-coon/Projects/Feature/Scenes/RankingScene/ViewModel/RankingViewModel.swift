//
//  RankingViewModel.swift
//  Feature
//
//  Created by 심관혁 on 1/2/26.
//

import Core
import Combine
import Foundation

/// 랭킹 화면의 비즈니스 로직을 담당하는 뷰모델
/// - 가족 구성원들의 포인트 기반 랭킹 계산 및 관리
/// - 실시간 데이터 로딩과 캐싱 전략 구현
/// - 현재 사용자의 랭킹 위치 계산
/// - ObservableObject를 통한 Combine 기반 반응형 UI 지원
public final class RankingViewModel: ObservableObject {
    @Published var familyMembers: [User] = []
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol

    /// 의존성 주입을 통한 뷰모델 초기화
    /// - Parameters:
    ///   - userService: 사용자 및 가족 구성원 정보 조회를 위한 서비스
    ///   - familyService: 가족 데이터 관리를 위한 서비스
    /// - Note: 랭킹 계산을 위해 사용자 서비스가 주로 사용되며
    ///         familyService는 추후 확장을 위한 예비 용도
    init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol
    ) {
        self.userService = userService
        self.familyService = familyService
    }

    /// 가족 구성원들의 랭킹 데이터를 비동기로 로드하는 메소드
    /// - 현재 사용자 정보 조회 및 가족 ID 확인
    /// - 가족 ID가 없는 경우 자동 동기화 시도
    /// - 가족 구성원 목록 조회 및 포인트 기준 정렬
    /// - UI 업데이트를 위해 MainActor에서 상태 변경 수행
    /// - Note: Swift Concurrency 기반 비동기 처리로 네트워크 지연 대응
    func loadRankingData() async {
        isLoading = true
        errorMessage = nil

        do {
            // 사용자 인증 상태 및 기본 정보 확인
            guard let currentUser = try await userService.getCurrentUser() else {
                errorMessage = "사용자 정보를 찾을 수 없습니다."
                isLoading = false
                return
            }

            self.currentUser = currentUser

            // 가족 소속 상태 확인 및 자동 복구
            var familyId = currentUser.familyId
            if familyId == nil {
                do {
                    // Firestore 문서 동기화로 가족 ID 복구 시도
                    try await userService.syncCurrentUserDocument()
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

            // 가족 구성원 데이터 조회 및 랭킹 계산
            let members = try await userService.getFamilyMembers(
                familyId: finalFamilyId
            )

            // 포인트 합계 기준 내림차순 정렬로 랭킹 생성
            let sortedMembers = members.sorted { $0.points > $1.points }

            // 메인 스레드에서 UI 상태 업데이트 수행
            await MainActor.run {
                self.familyMembers = sortedMembers
                self.isLoading = false
            }

        } catch {
            // 로딩 실패 시 사용자에게 에러 피드백
            await MainActor.run {
                self.errorMessage = "랭킹 데이터를 불러오는데 실패했습니다."
                self.isLoading = false
            }
        }
    }

    /// 현재 로그인한 사용자의 랭킹 순위를 계산하는 계산 속성
    /// - Returns: 1부터 시작하는 순위 번호 (1위, 2위 등)
    /// - Note: familyMembers 배열에서 현재 사용자의 위치를 찾아 1-based index로 반환
    ///         사용자가 목록에 없는 경우 nil 반환
    var currentUserRank: Int? {
        guard let currentUser = currentUser else { return nil }
        return familyMembers
            .firstIndex(where: { $0.id == currentUser.id })?
            .advanced(by: 1)  // 0-based index를 1-based rank로 변환
    }

    /// 랭킹 데이터 새로고침
    func refreshData() {
        Task {
            await loadRankingData()
        }
    }
}

// MARK: - 랭킹 표시용 User Extension

extension User {
    /// 랭킹 화면에서 포인트를 표시하기 위한 포맷된 문자열
    /// - Returns: "1250P" 형식의 포인트 표시 문자열
    var formattedPoints: String {
        return "\(points)P"
    }

    /// 순위에 따른 시각적 이모지 표현
    /// - Parameter rank: 표시할 순위 (1, 2, 3, ...)
    /// - Returns: 1-3위는 메달 이모지, 그 외는 숫자 표시
    func rankEmoji(rank: Int) -> String {
        switch rank {
        case 1: return "🥇"  // 금메달
        case 2: return "🥈"  // 은메달
        case 3: return "🥉"  // 동메달
        default: return "\(rank)."  // 그 외 순위는 숫자로 표시
        }
    }
}

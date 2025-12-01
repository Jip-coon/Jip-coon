//
//  ProfileEditViewModel.swift
//  Feature
//
//  Created by 예슬 on 11/30/25.
//

import Core
import Foundation

final class ProfileEditViewModel: ObservableObject {
    @Published var familyName: String = "우리 가족"
    private let user: User
    private let familyService: FamilyServiceProtocol
    
    init(
        user: User,
        familyService: FamilyServiceProtocol = FirebaseFamilyService()
    ) {
        self.user = user
        self.familyService = familyService
        Task {
            await loadFamilyName()
        }
    }
    
    private func loadFamilyName() async {
        do {
            let family = try await familyService.getFamily(by: user.id)
            self.familyName = family?.name ?? "우리 가족"
        } catch {
            print("가족 정보 로드 실패: \(error.localizedDescription)")
        }
    }
}

//
//  ProfileEditViewModel.swift
//  Feature
//
//  Created by 예슬 on 11/30/25.
//

import Combine
import Core
import Foundation

final class ProfileEditViewModel: ObservableObject {
    @Published var familyName: String = "우리 가족"
    @Published var user: User?
    @Published var enteredName: String = ""
    @Published var isNameChanged: Bool = true
    
    private let familyService: FamilyServiceProtocol
    private let userService: UserServiceProtocol
    
    init(
        familyService: FamilyServiceProtocol = FirebaseFamilyService(),
        userService: UserServiceProtocol = FirebaseUserService()
    ) {
        self.familyService = familyService
        self.userService = userService
        
        Task {
            self.user = try await self.userService.getCurrentUser()
            await loadFamilyName()
        }
        
        Publishers.CombineLatest($user, $enteredName)
            .map { user, enteredName in
                guard let originalName = user?.name, !enteredName.isEmpty else {
                    return false
                }
                return originalName != enteredName
            }
            .assign(to: &$isNameChanged)
    }
    
    private func loadFamilyName() async {
        do {
            guard let user = self.user,
                  let familyId = user.familyId
            else {
                print("현재 사용자 정보를 가져올 수 없습니다.")
                return
            }
            
            let family = try await familyService.getFamily(by: familyId)
            self.familyName = family?.name ?? "우리 가족"
        } catch {
            print("가족 정보 로드 실패: \(error.localizedDescription)")
        }
    }
    
    func updateProfileName(newName: String) async {
        do {
            guard let user = self.user else {
                print("현재 사용자 정보를 가져올 수 없습니다.")
                return
            }
            
            try await userService
                .updateUserName(userId: user.id, newName: newName)
            guard let updatedUser = try await userService.getUser(by: user.id) else {
                throw NSError(
                    domain: "ProfileEdit",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "업데이트된 사용자 정보를 찾을 수 없습니다."]
                )
            }
            self.user = updatedUser
        } catch {
            print("사용자 이름 변경 실패: \(error.localizedDescription)")
        }
    }
}

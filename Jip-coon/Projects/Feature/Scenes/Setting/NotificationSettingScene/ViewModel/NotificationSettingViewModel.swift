//
//  NotificationSettingViewModel.swift
//  Feature
//
//  Created by 예슬 on 2/8/26.
//

import Core
import Combine
import Foundation

final class NotificationSettingViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    
    @Published var settings: [NotificationSettingType: Bool] = [:]
    private(set) var isDataLoaded = false
    
    private let toggleSubject = PassthroughSubject<(NotificationSettingType, Bool), Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userService: UserServiceProtocol = FirebaseUserService()
    ) {
        self.userService = userService
        setupDebounce()
        fetchSettings() // 초기 데이터 가져오기
    }
    
    private func setupDebounce() {
        // 토글 이벤트가 들어오면 0.5초 동안 기다렸다가 마지막 값만 방출
        toggleSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] type, isOn in
                self?.updateSetting(type: type, isOn: isOn)
            }
            .store(in: &cancellables)
    }
    
    private func fetchSettings() {
        Task {
            do {
                // 서버에서 알림 설정 데이터 가져오기
                guard let user = try await userService.getCurrentUser(),
                      let settingsData = user.notificationSetting
                else {
                    print("알림 설정 데이터가 없습니다.")
                    return
                }
                
                // String 키를 NotificationSettingType 타입으로 변환
                let mappedSettings = settingsData.compactMap { (key, value) -> (NotificationSettingType, Bool)? in
                    // (매칭되는게 없으면 nil 반환하여 제외)
                    guard let type = NotificationSettingType(rawValue: key) else { return nil }
                    return (type, value)
                }
                
                // 알림 설정 상태 업데이트
                await MainActor.run {
                    self.settings = Dictionary(uniqueKeysWithValues: mappedSettings)
                    self.isDataLoaded = true
                }
            } catch {
                print("알림 설정 데이터를 가져오지 못했습니다.: \(error)")
            }
        }
    }
    
    func toggleSetting(type: NotificationSettingType, isOn: Bool) {
        settings[type] = isOn
        toggleSubject.send((type, isOn))
    }
    
    private func updateSetting(type: NotificationSettingType, isOn: Bool) {
        Task {
            do {
                // 서버에 저장
                try await userService.updateNotificationSetting(fieldName: type.firestoreFieldName, isOn: isOn)
            } catch {
                await MainActor.run {
                    // 스위치를 원래대로 돌려놓기
                    settings[type] = !isOn
                    print("서버 저장 실패 - 알림 설정 원래 상태로 복구")
                }
            }
        }
    }
}

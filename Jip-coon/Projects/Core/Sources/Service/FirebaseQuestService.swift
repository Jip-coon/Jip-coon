//
//  FirebaseQuestService.swift
//  Core
//
//  Created by 심관혁 on 12/31/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

/// Firebase Firestore를 사용하여 퀘스트 데이터를 관리하는 서비스 클래스
/// - CRUD 작업: 퀘스트 생성, 조회, 수정, 삭제 기능 제공
/// - 쿼리 작업: 가족별, 상태별, 카테고리별, 담당자별 퀘스트 조회
/// - 상태 관리: 퀘스트 진행 상태 변경 및 권한 검증
/// - 실시간 관찰: Combine Publisher를 통한 실시간 데이터 동기화
/// - 반복 퀘스트: 정기적인 퀘스트 자동 생성 기능
/// - 제출 및 검토: 퀘스트 완료 제출 및 승인/거절 처리
/// - 가상 퀘스트: 반복 퀘스트로 아직 실제 인스턴스가 생성되지 않은 퀘스트
///     - 예) 시작일: 1월 22일(목), 종료일: 2월 28일, 반복일: 매주 목요일
///     - 전체 탭 기준(오늘 ±7)에 해당하는 날짜에 반복 퀘스트가 있다면, 퀘스트를 메모리에서 생성해 UI에 보여줌
///     - 퀘스트 완료시에 실제 인스턴스가 생성되어 Firestore Quest로 저장됨
///     - 그래서 퀘스트를 완료하기 전까지는 UI에 보이지만 실제 Quest ID만으로는 작업 불가능
///     - virtual_ 로 시작하는지 확인하기!
public final class FirebaseQuestService: QuestServiceProtocol {
    private let db = Firestore.firestore()

    private var questsCollection: CollectionReference {
        return db.collection(FirestoreCollections.quests)
    }

    private var submissionsCollection: CollectionReference {
        return db.collection(FirestoreCollections.questSubmissions)
    }
    
    private var templatesCollection: CollectionReference {
        return db.collection(FirestoreCollections.questTemplates)
    }

    public init() { }

    // MARK: - CRUD 작업

    /// 새로운 퀘스트를 Firestore에 생성하는 메소드
    /// - Parameter quest: 생성할 퀘스트 정보 (id는 자동 생성됨)
    /// - Returns: 생성된 퀘스트 객체 (자동 생성된 ID 포함)
    /// - Note: Firestore의 자동 ID 생성 기능을 활용하며,
    ///         생성된 ID를 포함한 새로운 Quest 객체를 반환
    public func createQuest(_ quest: Quest) async throws -> Quest {
        do {
            // Firestore에서 자동 생성된 ID 사용
            let documentRef = questsCollection.document()
            let documentId = documentRef.documentID

            // 새로운 Quest 객체 생성 (document ID 사용)
            let questToSave = Quest(
                id: documentId,
                title: quest.title,
                description: quest.description,
                category: quest.category,
                assignedTo: quest.assignedTo,
                createdBy: quest.createdBy,
                familyId: quest.familyId,
                points: quest.points,
                dueDate: quest.dueDate
            )

            // Firestore에 저장
            try documentRef.setData(from: questToSave)

            return questToSave
        } catch {
            throw FirebaseQuestServiceError
                .creationFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 조회
    /// 가상 퀘스트는 가져올 수 없음
    public func getQuest(by id: String) async throws -> Quest? {
        do {
            let document = try await questsCollection.document(id).getDocument()

            if document.exists {
                return try document.data(as: Quest.self)
            } else {
                return nil
            }
        } catch {
            throw FirebaseQuestServiceError
                .fetchFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 업데이트
    public func updateQuest(_ quest: Quest) async throws {
        do {
            if quest.id.hasPrefix("virtual_") {
                if let templateId = quest.templateId {
                    try await templatesCollection.document(templateId).updateData([
                        FirestoreFields.QuestTemplate.title: quest.title,
                        FirestoreFields.QuestTemplate.description: quest.description ?? "",
                        FirestoreFields.QuestTemplate.category: quest.category.rawValue,
                        FirestoreFields.QuestTemplate.points: quest.points,
                        FirestoreFields.QuestTemplate.assignedTo: quest.assignedTo as Any,
                        FirestoreFields.QuestTemplate.recurringType: quest.recurringType.rawValue,
                        FirestoreFields.QuestTemplate.selectedRepeatDays: quest.selectedRepeatDays ?? [],
                        FirestoreFields.QuestTemplate.recurringEndDate: quest.recurringEndDate as Any, // 종료일 업데이트
                        FirestoreFields.QuestTemplate.updatedAt: Timestamp(date: Date())
                    ])
                }
                // 가상 퀘스트를 실제 문서로 등록
                _ = try await updateQuestStatus(quest: quest, status: quest.status)
            } else {
                try questsCollection.document(quest.id).setData(from: quest)
            }
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 삭제
    public func deleteQuest(id: String) async throws {
        do {
            try await questsCollection.document(id).delete()
        } catch {
            throw FirebaseQuestServiceError
                .deletionFailed(error.localizedDescription)
        }
    }

    // MARK: - 쿼리 작업

    /// 특정 가족의 모든 퀘스트를 조회하는 메소드
    /// - Parameter familyId: 조회할 가족의 ID
    /// - Returns: 해당 가족의 모든 퀘스트 목록 (생성일 기준 내림차순 정렬)
    /// - Note: Firestore의 whereField 쿼리를 사용하여 familyId 필터링 수행
    ///         현재는 인덱스 최적화를 위해 메모리에서 정렬하지만 추후 DB 레벨 정렬로 개선 예정
    public func getFamilyQuests(familyId: String) async throws -> [Quest] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 관찰 범위 설정 (오늘 전후 7일)
        let startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        let endDate = calendar.date(byAdding: .day, value: 7, to: today)!
        
        // 반복 로직이 포함된 전체 퀘스트 가져오기
        let quests = try await fetchQuestsWithRepeat(
            familyId: familyId,
            startDate: startDate,
            endDate: endDate
        )
        
        // [정렬 추가]
        // 1. 마감일(dueDate) 오름차순 (가장 가까운 일정이 위로)
        // 2. 마감일이 같다면 생성일(createdAt) 내림차순 (최신 등록 항목 위로)
        return quests.sorted {
            if let firstDue = $0.dueDate, let secondDue = $1.dueDate, firstDue != secondDue {
                return firstDue < secondDue
            }
            return $0.createdAt > $1.createdAt
        }
    }

    /// 상태별 퀘스트 조회
    public func getQuestsByStatus(familyId: String, status: QuestStatus) async throws -> [Quest] {
        let all = try await getFamilyQuests(familyId: familyId)
        return all.filter { $0.status == status }
    }

    /// 카테고리별 퀘스트 조회
    public func getQuestsByCategory(familyId: String, category: QuestCategory) async throws -> [Quest] {
        let all = try await getFamilyQuests(familyId: familyId)
        return all.filter { $0.category == category }
    }

    /// 담당자별 퀘스트 조회
    public func getQuestsByAssignee(userId: String, familyId: String) async throws -> [Quest] {
        let all = try await getFamilyQuests(familyId: familyId)
        return all.filter { $0.assignedTo == userId }
    }

    // MARK: - 상태 관리

    /// 퀘스트의 진행 상태를 변경하는 메소드
    /// - Parameters:
    ///   - quest: 상태를 변경할 퀘스트
    ///   - status: 변경할 새로운 상태
    /// - Note: 상태별로 적절한 타임스탬프 필드 자동 업데이트
    ///         (시작시간, 완료시간, 승인시간 등)
    ///         updatedAt 필드는 항상 현재 시간으로 갱신
    public func updateQuestStatus(quest: Quest, status: QuestStatus) async throws {
        do {
            // 가상 퀘스트(ID가 virtual_로 시작)인 경우 처리
            if quest.id.hasPrefix("virtual_") {
                let newDocRef = questsCollection.document()
                
                // 가상 퀘스트의 정보를 바탕으로 실제 DB에 저장할 객체를 새로 생성
                let finalQuest = Quest(
                    id: newDocRef.documentID,          // 가상 ID 대신 방금 만든 실제 문서 ID 사용
                    templateId: quest.templateId,      // 템플릿 ID 유지
                    title: quest.title,
                    description: quest.description,
                    category: quest.category,
                    status: status,
                    recurringType: quest.recurringType,
                    assignedTo: quest.assignedTo,
                    createdBy: quest.createdBy,
                    familyId: quest.familyId,
                    points: quest.points,
                    dueDate: quest.dueDate,            // 가상 퀘스트가 생성됐을때 그 날짜 유지
                    selectedRepeatDays: quest.selectedRepeatDays,
                    recurringEndDate: quest.recurringEndDate,
                    startedAt: status == .inProgress ? Date() : nil,
                    completedAt: status == .completed ? Date() : nil,
                    approvedAt: status == .approved ? Date() : nil,
                    updatedAt: Date()
                )
                
                // 가상 퀘스트를 실제 문서로 생성
                try newDocRef.setData(from: finalQuest)
            } else {
                var updateData: [String: Any] = [
                    FirestoreFields.Quest.status: status.rawValue,
                    FirestoreFields.Quest.updatedAt: Timestamp(date: Date())
                ]
                
                // 상태별 추가 필드 설정
                switch status {
                    case .inProgress:
                        updateData[FirestoreFields.Quest.startedAt] = Timestamp(
                            date: Date()
                        )
                    case .completed:
                        updateData[FirestoreFields.Quest.completedAt] = Timestamp(
                            date: Date()
                        )
                    case .approved:
                        updateData[FirestoreFields.Quest.approvedAt] = Timestamp(
                            date: Date()
                        )
                    case .rejected:
                        break // 거절 시 추가 필드 없음
                    case .pending:
                        break // 대기 시 추가 필드 없음
                }
                
                try await questsCollection.document(quest.id).updateData(updateData)
            }
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 담당자 지정
    public func assignQuest(quest: Quest, userId: String) async throws {
        do {
            if quest.id.hasPrefix("virtual_") {
                // 가상 퀘스트인 경우 담당자를 지정한 상태로 실제 문서 생성
                var updatedQuest = quest
                updatedQuest.assignedTo = userId
                _ = try await updateQuestStatus(quest: updatedQuest, status: .pending)
            } else {
                try await questsCollection.document(quest.id).updateData([
                    FirestoreFields.Quest.assignedTo: userId,
                    FirestoreFields.Quest.updatedAt: Timestamp(date: Date())
                ])
            }
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 시작
    public func startQuest(quest: Quest, userId: String) async throws {
        do {
            // 권한 확인: 담당자만 시작할 수 있음
            guard quest.assignedTo == userId else {
                throw FirebaseQuestServiceError.permissionDenied
            }

            guard quest.status == .pending else {
                throw FirebaseQuestServiceError
                    .invalidStatus("대기중인 퀘스트만 시작할 수 있습니다")
            }

            try await updateQuestStatus(quest: quest, status: .inProgress)
        } catch let error as FirebaseQuestServiceError {
            throw error
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    // MARK: - Submission & Review Workflow

    /// 퀘스트 완료 제출
    public func submitQuestCompletion(quest: Quest, submission: QuestSubmission) async throws {
        do {
            // 1. 퀘스트 상태를 completed로 변경
            try await updateQuestStatus(quest: quest, status: .completed)

            // 2. 제출 데이터 생성 (나중에 QuestSubmissionService로 분리 가능)
            try submissionsCollection
                .document(submission.id)
                .setData(from: submission)
        } catch {
            throw FirebaseQuestServiceError
                .submissionFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 승인/거절
    public func reviewQuest(questId: String, isApproved: Bool, reviewComment: String?, reviewerId: String, userService: UserServiceProtocol) async throws {
        do {
            // 1. 퀘스트 정보 조회
            guard let quest = try await getQuest(by: questId) else {
                throw FirebaseQuestServiceError.questNotFound
            }

            // 2. 퀘스트 상태 변경
            let newStatus: QuestStatus = isApproved ? .approved : .rejected
            try await updateQuestStatus(quest: quest, status: newStatus)

            // 3. 승인 시 포인트 지급
            if isApproved && quest.status == .completed {
                try await userService
                    .updateUserPoints(
                        userId: quest.assignedTo ?? "",
                        points: quest.points
                    )
            }

            // 2. 제출 데이터 업데이트 (해당 제출이 있다면)
            let submissionQuery = submissionsCollection
                .whereField("questId", isEqualTo: questId)
                .whereField("isApproved", isEqualTo: NSNull()) // 검토되지 않은 제출만

            let snapshot = try await submissionQuery.getDocuments()

            if let submissionDoc = snapshot.documents.first {
                var updateData: [String: Any] = [
                    "isApproved": isApproved,
                    "reviewedBy": reviewerId,
                    "reviewedAt": Timestamp(date: Date())
                ]

                if let reviewComment = reviewComment {
                    updateData["reviewComment"] = reviewComment
                }

                try await submissionDoc.reference.updateData(updateData)
            }
        } catch {
            throw FirebaseQuestServiceError
                .reviewFailed(error.localizedDescription)
        }
    }

    // MARK: - 실시간 데이터 관찰

    /// 가족의 퀘스트 목록을 실시간으로 관찰하는 메소드
    /// - Parameter familyId: 관찰할 가족의 ID
    /// - Returns: 퀘스트 배열을 방출하는 Combine Publisher
    /// - Note: Firestore의 addSnapshotListener를 사용하여 실시간 업데이트 수신
    ///         Publisher가 cancel되면 자동으로 리스너 제거
    ///         메모리 누수 방지를 위해 handleEvents를 사용하여 리스너 정리
    public func observeFamilyQuests(familyId: String) -> AnyPublisher<[Quest], Error> {
        let calendar = Calendar.current
        let questsPublisher = PassthroughSubject<[Quest], Error>()
        let templatesPublisher = PassthroughSubject<[QuestTemplate], Error>()
        
        // 관찰 범위 설정 (오늘 기준 앞뒤 7일)
        let today = Date()
        let obsStart = calendar.date(byAdding: .day, value: -7, to: today)!
        let obsEnd = calendar.date(byAdding: .day, value: 7, to: today)!
        
        // 실제 퀘스트 리스너
        let questsListener = questsCollection
            .whereField("familyId", isEqualTo: familyId)
            .whereField("dueDate", isGreaterThanOrEqualTo: calendar.startOfDay(for: obsStart))
            .whereField("dueDate", isLessThanOrEqualTo: obsEnd)
            .addSnapshotListener { snapshot, error in
                if let error = error { questsPublisher.send(completion: .failure(error)); return }
                let quests = snapshot?.documents.compactMap { try? $0.data(as: Quest.self) } ?? []
                questsPublisher.send(quests)
            }
        
        // 템플릿 리스너
        let templatesListener = templatesCollection
            .whereField("familyId", isEqualTo: familyId)
            .addSnapshotListener { snapshot, error in
                if let error = error { templatesPublisher.send(completion: .failure(error)); return }
                let templates = snapshot?.documents.compactMap { try? $0.data(as: QuestTemplate.self) } ?? []
                templatesPublisher.send(templates)
            }
        
        return Publishers.CombineLatest(questsPublisher, templatesPublisher)
            .map { [weak self] realQuests, templates in
                return self?.mergeRealAndVirtualQuests(
                    realQuests: realQuests,
                    templates: templates,
                    startDate: obsStart,
                    endDate: obsEnd
                ) ?? realQuests
            }
            .handleEvents(receiveCancel: {
                questsListener.remove()
                templatesListener.remove()
            })
            .eraseToAnyPublisher()
    }
    
    /// 실시간 퀘스트 상태 구독
    public func observeQuestStatus(questId: String) -> AnyPublisher<QuestStatus, Error> {
        let subject = PassthroughSubject<QuestStatus, Error>()
        
        let listener = questsCollection.document(questId)
            .addSnapshotListener {
                document,
                error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let document = document,
                      document.exists,
                      let quest = try? document.data(as: Quest.self) else {
                    return
                }
                
                subject.send(quest.status)
            }
        
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
    
    // MARK: - 반복 퀘스트 합성 로직 분리 (Private)
    
    /// 실제 퀘스트와 가상 퀘스트를 합쳐서 Quest 목록을 만들어 줍니다.
    /// - Parameters:
    ///   - realQuests: 실제 퀘스트(Firestore Quest에 저장되어 있음)
    ///   - templates: 가상 퀘스트(Firestore QuestTemplate에 저장되어 있음)
    ///   - startDate: 조회 시작 날짜
    ///   - endDate: 조회 종료 날짜
    /// - Returns: 실제 퀘스트 + 가상 퀘스트 (MainView, AllQuestView에서 사용)
    private func mergeRealAndVirtualQuests(
        realQuests: [Quest],
        templates: [QuestTemplate],
        startDate: Date,
        endDate: Date
    ) -> [Quest] {
        let calendar = Calendar.current
        
        // 시간 오차 제거를 위해 정규화
        let normalizedStart = calendar.startOfDay(for: startDate)
        let normalizedEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        var resultQuests = realQuests
        
        // 반복 규칙 검사
        for template in templates {
            var date = normalizedStart
            let templateStart = calendar.startOfDay(for: template.startDate)
            
            while date <= normalizedEnd {
                let currentDate = calendar.startOfDay(for: date)
                
                // 반복 퀘스트 시작일보다 현재 날짜가 이전이면 다음날로
                if currentDate < templateStart {
                    date = calendar.date(byAdding: .day, value: 1, to: date)!
                    continue
                }
                
                // 반복 퀘스트 종료일을 지났는지 확인
                if let templateEnd = template.recurringEndDate {
                    if currentDate > calendar.startOfDay(for: templateEnd) {
                        date = calendar.date(byAdding: .day, value: 1, to: date)!
                        break
                    }
                }
                
                // 오늘 날짜가 사용자가 선택한 반복 요일에 해당하는지 확인
                let weekday = calendar.component(.weekday, from: date) - 1 // 0(일)~6(토)
                if template.selectedRepeatDays.contains(weekday) {
                    // 이미 Firestore에 실제 데이터가 존재하는지
                    let isAlreadyExists = realQuests.contains { real in
                        real.templateId == template.id &&
                        calendar.isDate(real.dueDate ?? Date(), inSameDayAs: date)
                    }
                    
                    if !isAlreadyExists {
                        resultQuests.append(createVirtualQuest(from: template, on: date))
                    }
                }
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        return resultQuests.sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
    }
    
    /// 가상 퀘스트 객체 생성 헬퍼
    private func createVirtualQuest(from template: QuestTemplate, on date: Date) -> Quest {
        return Quest(
            id: "virtual_\(template.id)_\(date.timeIntervalSince1970)",
            templateId: template.id,
            title: template.title,
            description: template.description,
            category: template.category,
            status: .pending,
            recurringType: template.recurringType,
            assignedTo: template.assignedTo,
            createdBy: template.createdBy,
            familyId: template.familyId,
            points: template.points,
            dueDate: date,
            selectedRepeatDays: template.selectedRepeatDays,
            recurringEndDate: template.recurringEndDate
        )
    }
    
    // MARK: - Recurring Quests
    
    /// 퀘스트 템플릿 생성
    /// - 반복 퀘스트 생성
    public func createQuestTemplate(_ template: QuestTemplate) async throws {
        try templatesCollection.document(template.id).setData(from: template)
    }
    
    /// 실제 퀘스트 + 가상 퀘스트 조회
    /// - Parameters:
    ///   - familyId: 가족 ID
    ///   - startDate: 조회 시작 날짜
    ///   - endDate: 조회 종료 날짜
    /// - Returns: 퀘스트
    /// - Note: 실제 퀘스트와 반복 규칙에 따라 만든 가상 데이터를 하나의 [Quset] 배열로 합쳐 조회해줍니다.
    public func fetchQuestsWithRepeat(
        familyId: String,
        startDate: Date,
        endDate: Date
    ) async throws -> [Quest] {
        let calendar = Calendar.current
        // 1. 실제 데이터 가져오기
        let snapshot = try await questsCollection
            .whereField(FirestoreFields.Quest.familyId, isEqualTo: familyId)
            .whereField(FirestoreFields.Quest.dueDate, isGreaterThanOrEqualTo: calendar.startOfDay(for: startDate))
            .whereField(FirestoreFields.Quest.dueDate, isLessThanOrEqualTo: calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!)
            .getDocuments()
        
        let realQuests = snapshot.documents.compactMap { try? $0.data(as: Quest.self) }
        
        // 2. 템플릿 가져오기
        let templateSnapshot = try await templatesCollection
            .whereField(FirestoreFields.QuestTemplate.familyId, isEqualTo: familyId)
            .getDocuments()
        
        let templates = templateSnapshot.documents.compactMap { try? $0.data(as: QuestTemplate.self) }
        
        // 3. 병합 함수를 사용하여 병합 후 반환
        return mergeRealAndVirtualQuests(
            realQuests: realQuests,
            templates: templates,
            startDate: startDate,
            endDate: endDate
        )
    }
}

// MARK: - Error Types

enum FirebaseQuestServiceError: LocalizedError {
    case questNotFound
    case permissionDenied
    case invalidStatus(String)
    case creationFailed(String)
    case fetchFailed(String)
    case updateFailed(String)
    case deletionFailed(String)
    case queryFailed(String)
    case submissionFailed(String)
    case reviewFailed(String)
    
    var errorDescription: String? {
        switch self {
            case .questNotFound:
                return "퀘스트를 찾을 수 없습니다"
            case .permissionDenied:
                return "권한이 없습니다"
            case .invalidStatus(let message):
                return message
            case .creationFailed(let details):
                return "퀘스트 생성에 실패했습니다: \(details)"
            case .fetchFailed(let details):
                return "퀘스트 조회에 실패했습니다: \(details)"
            case .updateFailed(let details):
                return "퀘스트 수정에 실패했습니다: \(details)"
            case .deletionFailed(let details):
                return "퀘스트 삭제에 실패했습니다: \(details)"
            case .queryFailed(let details):
                return "퀘스트 검색에 실패했습니다: \(details)"
            case .submissionFailed(let details):
                return "제출에 실패했습니다: \(details)"
            case .reviewFailed(let details):
                return "검토에 실패했습니다: \(details)"
        }
    }
}

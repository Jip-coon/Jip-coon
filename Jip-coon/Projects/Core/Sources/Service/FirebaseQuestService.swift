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

public final class FirebaseQuestService: QuestServiceProtocol {
    private let db = Firestore.firestore()

    private var questsCollection: CollectionReference {
        return db.collection(FirestoreCollections.quests)
    }

    private var submissionsCollection: CollectionReference {
        return db.collection(FirestoreCollections.questSubmissions)
    }

    public init() { }

    // MARK: - CRUD Operations

    /// 퀘스트 생성
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
                createdBy: quest.createdBy,
                familyId: quest.familyId,
                points: quest.points
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
            try questsCollection.document(quest.id).setData(from: quest)
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

    // MARK: - Query Operations

    /// 가족의 모든 퀘스트 조회
    public func getFamilyQuests(familyId: String) async throws -> [Quest] {
        do {
            // 임시: 정렬 없이 조회 (나중에 인덱스 생성 후 정렬 추가)
            let snapshot = try await questsCollection
                .whereField(FirestoreFields.Quest.familyId, isEqualTo: familyId)
                .getDocuments()

            let quests = snapshot.documents.compactMap { document in
                try? document.data(as: Quest.self)
            }

            // 메모리에서 createdAt 내림차순 정렬
            return quests.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw FirebaseQuestServiceError
                .queryFailed(error.localizedDescription)
        }
    }

    /// 상태별 퀘스트 조회
    public func getQuestsByStatus(familyId: String, status: QuestStatus) async throws -> [Quest] {
        do {
            // 임시: 정렬 없이 조회 (나중에 인덱스 생성 후 정렬 추가)
            let snapshot = try await questsCollection
                .whereField(FirestoreFields.Quest.familyId, isEqualTo: familyId)
                .whereField(
                    FirestoreFields.Quest.status,
                    isEqualTo: status.rawValue
                )
                .getDocuments()

            let quests = snapshot.documents.compactMap { document in
                try? document.data(as: Quest.self)
            }

            // 메모리에서 createdAt 내림차순 정렬
            return quests.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw FirebaseQuestServiceError
                .queryFailed(error.localizedDescription)
        }
    }

    /// 카테고리별 퀘스트 조회
    public func getQuestsByCategory(familyId: String, category: QuestCategory) async throws -> [Quest] {
        do {
            // 임시: 정렬 없이 조회 (나중에 인덱스 생성 후 정렬 추가)
            let snapshot = try await questsCollection
                .whereField(FirestoreFields.Quest.familyId, isEqualTo: familyId)
                .whereField(
                    FirestoreFields.Quest.category,
                    isEqualTo: category.rawValue
                )
                .getDocuments()

            let quests = snapshot.documents.compactMap { document in
                try? document.data(as: Quest.self)
            }

            // 메모리에서 createdAt 내림차순 정렬
            return quests.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw FirebaseQuestServiceError
                .queryFailed(error.localizedDescription)
        }
    }

    /// 담당자별 퀘스트 조회
    public func getQuestsByAssignee(userId: String) async throws -> [Quest] {
        do {
            // 임시: 정렬 없이 조회 (나중에 인덱스 생성 후 정렬 추가)
            let snapshot = try await questsCollection
                .whereField(FirestoreFields.Quest.assignedTo, isEqualTo: userId)
                .getDocuments()

            let quests = snapshot.documents.compactMap { document in
                try? document.data(as: Quest.self)
            }

            // 메모리에서 createdAt 내림차순 정렬
            return quests.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw FirebaseQuestServiceError
                .queryFailed(error.localizedDescription)
        }
    }

    // MARK: - State Management

    /// 퀘스트 상태 변경
    public func updateQuestStatus(questId: String, status: QuestStatus) async throws {
        do {
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

            try await questsCollection.document(questId).updateData(updateData)
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 담당자 지정
    public func assignQuest(questId: String, userId: String) async throws {
        do {
            try await questsCollection.document(questId).updateData([
                FirestoreFields.Quest.assignedTo: userId,
                FirestoreFields.Quest.updatedAt: Timestamp(date: Date())
            ])
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    /// 퀘스트 시작
    public func startQuest(questId: String, userId: String) async throws {
        do {
            // 권한 확인: 담당자만 시작할 수 있음
            guard let quest = try await getQuest(by: questId) else {
                throw FirebaseQuestServiceError.questNotFound
            }

            guard quest.assignedTo == userId else {
                throw FirebaseQuestServiceError.permissionDenied
            }

            guard quest.status == .pending else {
                throw FirebaseQuestServiceError
                    .invalidStatus("대기중인 퀘스트만 시작할 수 있습니다")
            }

            try await updateQuestStatus(questId: questId, status: .inProgress)
        } catch let error as FirebaseQuestServiceError {
            throw error
        } catch {
            throw FirebaseQuestServiceError
                .updateFailed(error.localizedDescription)
        }
    }

    // MARK: - Submission & Review Workflow

    /// 퀘스트 완료 제출
    public func submitQuestCompletion(questId: String, submission: QuestSubmission) async throws {
        do {
            // 1. 퀘스트 상태를 completed로 변경
            try await updateQuestStatus(questId: questId, status: .completed)

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
            try await updateQuestStatus(questId: questId, status: newStatus)

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

    // MARK: - Real-time Observers

    /// 실시간 퀘스트 목록 구독
    public func observeFamilyQuests(familyId: String) -> AnyPublisher<[Quest], Error> {
        let subject = PassthroughSubject<[Quest], Error>()

        // 임시: 정렬 없이 리스닝 (나중에 인덱스 생성 후 정렬 추가)
        let listener = questsCollection
            .whereField(FirestoreFields.Quest.familyId, isEqualTo: familyId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let quests = documents.compactMap { document in
                    try? document.data(as: Quest.self)
                }

                // 메모리에서 createdAt 내림차순 정렬
                let sortedQuests = quests.sorted { $0.createdAt > $1.createdAt }
                subject.send(sortedQuests)
            }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
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

    // MARK: - Recurring Quests

    /// 반복 퀘스트 생성
    public func createRecurringQuest(baseQuest: Quest, targetDate: Date) async throws -> Quest {
        do {
            // Firestore에서 자동 생성된 ID 사용
            let documentRef = questsCollection.document()
            let documentId = documentRef.documentID

            // 새로운 Quest 객체 생성 (createdAt 지정)
            let questToSave = Quest(
                id: documentId,
                title: baseQuest.title,
                description: baseQuest.description,
                category: baseQuest.category,
                createdBy: baseQuest.createdBy,
                familyId: baseQuest.familyId,
                points: baseQuest.points,
                createdAt: Date()  // 새로운 생성 시간
            )

            // 추가 속성 설정을 위해 임시 객체 생성 (수정 가능한 필드만)
            var finalQuest = questToSave
            finalQuest.dueDate = targetDate
            finalQuest.recurringType = baseQuest.recurringType
            finalQuest.updatedAt = Date()

            // Firestore에 저장
            try documentRef.setData(from: finalQuest)

            return finalQuest
        } catch {
            throw FirebaseQuestServiceError
                .creationFailed(error.localizedDescription)
        }
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

//
//  FirebaseNotificationService.swift
//  Core
//
//  Created by 예슬 on 2/11/26.
//

import FirebaseFirestore
import Foundation

public final class FirebaseNotificationService: NotificationServiceProtocol {
    private let db = Firestore.firestore()
    
    private var usersCollection: CollectionReference {
        return db.collection(FirestoreCollections.users)
    }
    
    public init() {}
    
    // MARK: - Fetch Data
    
    public func fetchNotifications(userId: String) async throws -> [NotificationItem] {
        let snapshot = try await usersCollection
            .document(userId)
            .collection(FirestoreCollections.notifications)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        // Firestore의 문서를 NotificationItem 모델로 변환
        let items = snapshot.documents.compactMap { document -> NotificationItem? in
            try? document.data(as: NotificationItem.self)
        }
        
        return items
    }
}

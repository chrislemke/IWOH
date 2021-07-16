import Combine
import FirebaseFirestore

public struct UserManager: UserManagerTyp {

	private let firestoreManager = FirestoreManager()
	private let authenticationManager = AuthenticationManager()

	// MARK: - Lifecycle
	public init() {}

	// MARK: - Public

	public func add(fcmToken: String) {
		guard let userID = authenticationManager.currentUserID else {
			return
		}

		let data = [FirestoreUser.CollectionFields.fcmToken: fcmToken]
		_ = firestoreManager.updateData(FirestoreUser.self, id: userID, data: data)
	}

	public func likePost(_ postID: String) -> AnyPublisher<Bool, Never> {
		firestoreManager.updateData(FirestorePost.self,
									id: postID,
									data: [FirestorePost.Fields.likes:
										FieldValue.increment(Int64(1))])
	}

	public func addLikeToUser(_ postID: String) -> AnyPublisher<Bool, Never> {
		guard let userID = authenticationManager.currentUserID else {
			return Just<Bool>(false).eraseToAnyPublisher()
		}
		let documentPath = firestoreManager.documentPath(FirestorePost.self, id: postID)
		return firestoreManager.addReferenceToSubcollection(sourceType: FirestoreUser.self,
													 id: userID,
													 referencedID: postID,
													 referencedDocumentPath: documentPath,
													 subcollectionPath: FirestoreUser.SubcollectionPath.likedPosts)
	}

	public func isLikedByUser(_ postID: String) -> AnyPublisher<Bool, Never> {
		guard let userID = authenticationManager.currentUserID else {
			return Just<Bool>(false).eraseToAnyPublisher()
		}

		return firestoreManager.isDocumentExistingInSubcollection(FirestoreUser.self,
																  id: userID,
																  documentID: postID,
																  subcollectionPath: FirestoreUser.SubcollectionPath.likedPosts)
	}

	public func isCreatedByUser(_ post: Post) -> AnyPublisher<Bool, Never> {
		guard let userID = authenticationManager.currentUserID else {
			return Just<Bool>(false).eraseToAnyPublisher()
		}
		return Just<Bool>(userID == post.creatorID).eraseToAnyPublisher()
	}
}

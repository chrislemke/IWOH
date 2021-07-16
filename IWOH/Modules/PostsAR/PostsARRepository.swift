import Foundation
import Combine
import IWOHInteractionKit

struct PostsARRepository: PostARRepositoryTyp {

	private let firestoreManager: FirestoreManagerTyp

	var posts: AnyPublisher<[Post], Never> {
		firestoreManager.listen(FirestorePost.self, order: Order(field: .date, descending: true))
			.map { posts in
				posts.map { Post(firestorePost: $0) }
			}.eraseToAnyPublisher()
	}

	// MARK: - Lifecycle
	init(firestoreManager: FirestoreManagerTyp) {
		self.firestoreManager = firestoreManager
	}
}

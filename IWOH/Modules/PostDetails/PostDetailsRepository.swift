import Combine
import IWOHInteractionKit

struct PostDetailsRepository: PostDetailsRepositoryTyp {

	private let locationManager: LocationManagerTyp
	private let userManager: UserManagerTyp
	private let firestoreManager: FirestoreManagerTyp

	// MARK: - Lifecycle
	init(locationManager: LocationManagerTyp, userManager: UserManagerTyp, firestoreManager: FirestoreManagerTyp) {
		self.locationManager = locationManager
		self.userManager = userManager
		self.firestoreManager = firestoreManager
	}

	// MARK: - Public
	func currentLocationDistance(location: Location) -> Double? {
		locationManager.distance(from: location)
	}

	func canLikePost(_ post: Post) -> AnyPublisher<Bool, Never> {
		Publishers.CombineLatest(userManager.isLikedByUser(post.id.uuidString),
								 userManager.isCreatedByUser(post)
		).map { !$0 && !$1 }.eraseToAnyPublisher()
	}

	func likePost(_ post: Post) -> AnyPublisher<Bool, Never> {
		Publishers.CombineLatest(
			userManager.likePost(post.id.uuidString),
			userManager.addLikeToUser(post.id.uuidString)
		).map {$0 && $1 }.eraseToAnyPublisher()
	}

	func likes(for post: Post) -> AnyPublisher<UInt, Never> {
		firestoreManager.get(FirestorePost.self, id: post.id.uuidString)
			.map { Post(firestorePost: $0) }
		.map { $0.likes }.eraseToAnyPublisher()
	}

	func distance(from location: Location) -> Double? {
		locationManager.distance(from: location)
	}
}

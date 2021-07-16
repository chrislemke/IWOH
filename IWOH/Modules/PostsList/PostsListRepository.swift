import Foundation
import Combine
import IWOHInteractionKit

struct PostsListRepository {

	private let firestoreManager: FirestoreManager
	private let authenticationManager: AuthenticationManager
	private let locationManager: LocationManager

	// MARK: - Lifecycle
	init(firestoreManager: FirestoreManager,
		 authenticationManager: AuthenticationManager,
		 locationManager: LocationManager) {
		self.firestoreManager = firestoreManager
		self.authenticationManager = authenticationManager
		self.locationManager = locationManager
		locationManager.requestLocation()
		authenticationManager.configureAccessGroup()
	}

	// MARK: - Public
	var posts: AnyPublisher<[Post], Never> {
		signInUser()
			.flatMap { _ -> AnyPublisher<[FirestorePost], Never> in
				 self.firestoreManager.listen(FirestorePost.self, order: Order(field: .date, descending: true))
			}
			.map { posts in
				posts.map {
					let post = Post(firestorePost: $0)
					SpotlightManager.indexItem(post: post)
					return post
				}
		}.eraseToAnyPublisher()
	}

	func location() -> AnyPublisher<LocationManager.State, Never> {
		locationManager.currentLocation
	}

	func requestLocation() {
		locationManager.setAccuracy(.tenMeters)
		locationManager.requestLocation()
	}

	// MARK: - Private
	private func signInUser() -> AnyPublisher<Void, Never> {
		return authenticationManager.signIn()
			.map { userID in
					_ = self.firestoreManager.add(FirestoreUser(user: User(id: userID, lastLogin: Date())))
		}.eraseToAnyPublisher()
	}
}

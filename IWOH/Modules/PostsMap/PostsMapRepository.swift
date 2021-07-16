import Combine
import IWOHInteractionKit

struct PostsMapRepository: PostsMapRepositoryTyp {
	
	var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> {
		locationManager.authenticationStatus
	}

	var location: LocationManager.State {
		locationManager.location
	}

	var currentLocation: AnyPublisher<LocationManager.State, Never> {
		locationManager.currentLocation
	}

	var locationHeading: AnyPublisher<LocationHeading?, Never> {
		locationManager.locationHeading
	}

	var posts: AnyPublisher<[Post], Never> {
		firestoreManager.listen(FirestorePost.self, order: Order(field: .date, descending: true))
			.map { posts in
				posts.map { Post(firestorePost: $0) }
			}
		.eraseToAnyPublisher()
	}

	private let locationManager: LocationManager
	private let firestoreManager: FirestoreManagerTyp

	// MARK: - Lifecycle
	init(locationManager: LocationManager, firestoreManager: FirestoreManagerTyp) {
		self.locationManager = locationManager
		self.firestoreManager = firestoreManager
	}

	// MARK: - Public
	func distance(from location: Location) -> Double? {
		locationManager.distance(from: location)
	}

	func startUpdatingLocation() {
		locationManager.setAccuracy(.best)
		locationManager.startUpdatingLocation()
	}

	func stopUpdatingLocation() {
		locationManager.stopUpdatingLocation()
		locationManager.setAccuracy(.tenMeters)
	}
}

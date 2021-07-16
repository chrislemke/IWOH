import Foundation
import Combine
import IWOHInteractionKit

struct CreatePostRepository: CreatePostRepositoryTyp {

	var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> {
		locationManager.authenticationStatus
	}

	var location: AnyPublisher<LocationManager.State, Never> {
		locationManager.currentLocation
	}

	var locationHeading: AnyPublisher<LocationHeading?, Never> {
		locationManager.locationHeading
	}

	private let firestoreManager: FirestoreManagerTyp
	private let locationManager: LocationManagerTyp
	private let mlManager: MLManagerTyp
	private let userManager: UserManagerTyp
	private let authenticationManager: AuthenticationManager

	// MARK: - Lifecycle
	init(locationManager: LocationManagerTyp,
		 firestoreManager: FirestoreManagerTyp,
		 mlManager: MLManagerTyp,
		 userManager: UserManagerTyp,
		 authenticationManager: AuthenticationManager) {
		self.locationManager = locationManager
		self.firestoreManager = firestoreManager
		self.mlManager = mlManager
		self.userManager = userManager
		self.authenticationManager = authenticationManager
	}

	// MARK: - Public

	func requestLocation() {
		locationManager.requestLocation()
	}

	func setLocationAccuracy(_ accuracy: LocationManager.Accuracy) {
		locationManager.setAccuracy(accuracy)
	}

	func submit(postMessage: PostMessage) -> AnyPublisher<SubmissionState, Never> {
		return Publishers.CombineLatest(mlManager.detectLanguage(for: postMessage.message), locationHeading)
		.first()
			.map { languageCode, heading in
				Post(message: postMessage.message,
					 location: postMessage.location,
					 heading: heading,
					 date: Date(),
					 languageCode: languageCode,
					 likes: 0,
					 creatorID: self.authenticationManager.currentUserID ?? "")
		}
		.flatMap {  post in
			self.firestoreManager.add(FirestorePost(post: post))
		}
		.eraseToAnyPublisher()
	}
}

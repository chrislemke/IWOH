import Intents
import Combine
import IWOHInteractionKit
import Contacts

final class GetClosestPostIntentHandler: NSObject, GetClosestPostIntentHandling {

	private var cancellableSet = Set<AnyCancellable>()
	private let firestoreManager = FirestoreManager()
	private let authenticationManager = AuthenticationManager()
	private var locationManager: LocationManager?

	override init() {
		super.init()
		OperationQueue.main.addOperation {
			self.locationManager = LocationManager()
		}
	}

	// MARK: - Public
	func handle(intent: GetClosestPostIntent, completion: @escaping (GetClosestPostIntentResponse) -> ()) {
		authenticationManager.configureAccessGroup()
		OperationQueue.main.addOperation { [weak self] in

			guard let self = self, let locationManager = self.locationManager else {
				completion(GetClosestPostIntentResponse(code: .failure, userActivity: nil))
				return
			}

			switch locationManager.location {
				case .error, .unspecified:
					completion(GetClosestPostIntentResponse(code: .failureNoLocation, userActivity: nil))
					return 
				case .location(let location):
					let locationGeohash = GeohashManager.geohash(for: location)
					let upperGeohash = GeohashManager.upperGeohash(from: location, offset: -3)

					let query = self.firestoreManager.rangeQuery(FirestorePost.self,
																 isGreaterThanEqualTo: locationGeohash,
																 isLessThan: upperGeohash,
																 field: FirestorePost.CollectionFields.geohash,
																 limit: 5)

					self.firestoreManager.get(FirestorePost.self, query: query)
						.sink { [weak self] firestorePosts in

							guard let self = self,
								let closestPost = self.closestPost(firestorePosts: firestorePosts, locationGeohash: locationGeohash) else {
								completion(GetClosestPostIntentResponse(code: .failureNoPostsFound, userActivity: nil))
								return
							}

							completion(self.response(closestPost, userLocation: location))
					}
					.store(in: &self.cancellableSet)
			}
			TrackingManager.track(.closestIntentCTA)
		}
	}

	func confirm(intent: GetClosestPostIntent, completion: @escaping (GetClosestPostIntentResponse) -> ()) {
		OperationQueue.main.addOperation { [weak self] in

			guard let self = self, let locationManager = self.locationManager else {
				return
			}

			if locationManager.isServiceAuthorizedAndEnabled() == false {
				completion(GetClosestPostIntentResponse(code: .failureNoLocation, userActivity: nil))
				return
			}
		}
		completion(GetClosestPostIntentResponse(code: .ready, userActivity: nil))
	}

	private func closestPost(firestorePosts: [FirestorePost], locationGeohash: String) -> FirestorePost? {
		let geohashes = firestorePosts.map { firestorePost in
			GeohashManager.geohash(for: Location(latitude: firestorePost.coordinates.latitude,
												 longitude: firestorePost.coordinates.longitude,
												 altitude: firestorePost.altitude))
		}

		guard let closestGeohash = GeohashManager.closestHash(locationGeohash, locations: geohashes),
			let closestPost = firestorePosts.first(where: { post in
			post.geohash == closestGeohash
		}) else {
			return nil
		}
		return closestPost
	}

	private func response(_ post: FirestorePost, userLocation: Location) -> GetClosestPostIntentResponse {

		let userActivity = NSUserActivity(activityType:
			kClosestPostActivityType)
		userActivity.userInfo = [kPostID: post.id]

		let response = GetClosestPostIntentResponse(code: .success, userActivity: userActivity)

		let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
		let userLocationPlacemark = CLPlacemark(location: userLocation, name: "userLocation", postalAddress: nil)

		let annotationLocation = CLLocation(latitude: post.coordinates.latitude,
											longitude: post.coordinates.longitude)
		let annotationLocationPlacemark = CLPlacemark(location: annotationLocation,
													  name: "annotationLocation", postalAddress: nil)

		response.userLocation = userLocationPlacemark
		response.annotationLocation = annotationLocationPlacemark
		response.message = post.message
		response.date = post.date.dateWithYear()

		return response
	}
}

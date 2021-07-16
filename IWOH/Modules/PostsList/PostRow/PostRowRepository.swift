import Combine
import IWOHInteractionKit

struct PostRowRepository {

	private let locationManager: LocationManager

    init(locationManager: LocationManager) {
		self.locationManager = locationManager
	}

	func location() -> AnyPublisher<LocationManager.State, Never> {
		locationManager.currentLocation
	}

	func distance(from location: Location) -> Double? {
		locationManager.distance(from: location)
	}
}

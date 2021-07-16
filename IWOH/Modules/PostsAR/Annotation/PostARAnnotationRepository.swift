import Combine
import IWOHInteractionKit

struct PostARAnnotationRepository {

	private let locationManager: LocationManager

	init(locationManager: LocationManager) {
		self.locationManager = locationManager
	}

	func distance(from location: Location) -> Double? {
		locationManager.distance(from: location)
	}
}

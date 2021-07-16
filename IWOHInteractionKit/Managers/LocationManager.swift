import Foundation
import CoreLocation
import Combine

public enum LocationAuthenticationStatus: Int32 {
	case notDetermined
	case restricted
	case denied
	case authorizedWhenInUse = 4
}

public final class LocationManager: NSObject, LocationManagerTyp {

	public enum Accuracy: Double {
		case best = -2
		case good = -1
		case tenMeters = 10
		case hundredMeters = 100
	}

	public enum State {
		case location(Location)
		case error
		case unspecified
	}

	public var authenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> {
		authenticationStatusSubject.eraseToAnyPublisher()
	}

	public var locationHeading: AnyPublisher<LocationHeading?, Never> {
		locationHeadingSubject.eraseToAnyPublisher()
	}

	public var currentLocation: AnyPublisher<State, Never> {
		return currentLocationSubject
			.debounce(for: 1.5, scheduler: RunLoop.current)
			.eraseToAnyPublisher()
	}

	public var location: State {
		guard let location = locationManager.location else {
			return .unspecified
		}
		return State.location(Location(latitude: location.coordinate.latitude,
									   longitude: location.coordinate.longitude,
									   altitude: location.coordinate.latitude))
	}

	private var cancellableSet = Set<AnyCancellable>()
	private let locationManager = CLLocationManager()
	private let authenticationStatusSubject = CurrentValueSubject<LocationAuthenticationStatus, Never>(.notDetermined)
	private let locationHeadingSubject = CurrentValueSubject<LocationHeading?, Never>(nil)
	private let currentLocationSubject = CurrentValueSubject<State, Never>(State.unspecified)

	// MARK: - Lifecycle
	public override init() {
		super.init()
		setupLocationManager()
	}

	// MARK: - Public
	public func isServiceAuthorizedAndEnabled() -> Bool {
		return isServiceAuthorized() && isServiceEnabled()
	}

	public func requestWhenInUseAuthorization() {
		if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.requestWhenInUseAuthorization()
		}
		requestLocation()
	}

	public func requestLocation() {
		locationManager.requestLocation()
	}

	public func startUpdatingLocation() {
		locationManager.startUpdatingLocation()
		locationManager.startUpdatingHeading()
	}

	public func stopUpdatingLocation() {
		locationManager.stopUpdatingLocation()
		locationManager.stopUpdatingHeading()
	}

	public func distance(from currentLocation: Location) -> Double? {
		let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
		if locationManager.location == nil {
			requestLocation()
		}
		return locationManager.location?.distance(from: location)
	}

	public func setAccuracy(_ accuracy: Accuracy) {
		locationManager.desiredAccuracy = accuracy.rawValue
	}

	// MARK: - Private
	private func setupLocationManager() {
		if CLLocationManager.locationServicesEnabled() {
			locationManager.desiredAccuracy = Accuracy.hundredMeters.rawValue
			locationManager.distanceFilter = 10.0
			locationManager.activityType = .fitness
			locationManager.delegate = self
		}
	}

	private func isServiceAuthorized() -> Bool {
		return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
	}

	private func isServiceEnabled() -> Bool {
		return CLLocationManager.locationServicesEnabled()
	}
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			logError("Could not get location. Error: \(error)!")
		}
	}

	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		authenticationStatusSubject.send(LocationAuthenticationStatus(rawValue: status.rawValue) ?? .notDetermined)
		if status == .authorizedWhenInUse {
			locationManager.requestLocation()
		}
	}

	public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		locationHeadingSubject.send(LocationHeading(trueHeading: newHeading.trueHeading))
	}

	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let clLocation = locations.first else {
			return
		}

		let location = Location(latitude: clLocation.coordinate.latitude,
								longitude: clLocation.coordinate.longitude,
								altitude: clLocation.altitude)
		currentLocationSubject.send(.location(location))
	}
}

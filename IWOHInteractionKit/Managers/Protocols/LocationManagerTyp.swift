import Combine

/// @mockable
public protocol LocationManagerTyp {

	var authenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> { get }
	var locationHeading: AnyPublisher<LocationHeading?, Never> { get }
	var currentLocation: AnyPublisher<LocationManager.State, Never> { get }
	var location: LocationManager.State { get }
	
	func requestWhenInUseAuthorization()
	func requestLocation()
	func setAccuracy(_ accuracy: LocationManager.Accuracy)
	func distance(from currentLocation: Location) -> Double?
}

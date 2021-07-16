import Combine
import IWOHInteractionKit

/// @mockable
protocol PostsMapRepositoryTyp {

	var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> { get }
	var currentLocation: AnyPublisher<LocationManager.State, Never> { get }
	var locationHeading: AnyPublisher<LocationHeading?, Never> { get }
	var posts: AnyPublisher<[Post], Never> { get }
	var location: LocationManager.State { get }

	func distance(from location: Location) -> Double?
	func startUpdatingLocation()
	func stopUpdatingLocation()
}

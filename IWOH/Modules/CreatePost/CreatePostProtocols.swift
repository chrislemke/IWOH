import Combine
import IWOHInteractionKit

/// @mockable
protocol CreatePostRepositoryTyp {
	var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> { get }
	var location: AnyPublisher<LocationManager.State, Never> { get }
	var locationHeading: AnyPublisher<LocationHeading?, Never> { get }

	func requestLocation()
	func setLocationAccuracy(_ accuracy: LocationManager.Accuracy)

	func submit(postMessage: PostMessage) -> AnyPublisher<SubmissionState, Never>
}

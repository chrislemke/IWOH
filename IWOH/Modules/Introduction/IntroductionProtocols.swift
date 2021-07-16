import Combine
import IWOHInteractionKit

/// @mockable
protocol IntroductionRepositoryTyp {

	var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> { get }

	func requestLocationAuthorization()

	func requestNotificationAuthorization()
}

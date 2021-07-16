import Combine
import IWOHInteractionKit

struct IntroductionRepository: IntroductionRepositoryTyp {

	var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> {
		locationManager.authenticationStatus
	}

	private let locationManager: LocationManager
	private let userDefaultsManager: UserDefaultsManager
	private let pushNotificationManager: PushNotificationManager

	init(locationManager: LocationManager,
		 userDefaultsManager: UserDefaultsManager,
		 pushNotificationManager: PushNotificationManager) {
		self.locationManager = locationManager
		self.userDefaultsManager = userDefaultsManager
		self.pushNotificationManager = pushNotificationManager
	}

	func requestNotificationAuthorization() {
		_ = pushNotificationManager.register()
	}

	func requestLocationAuthorization() {
		locationManager.requestWhenInUseAuthorization()
	}
}

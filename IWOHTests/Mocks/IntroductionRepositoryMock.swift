///
/// @Generated by Mockolo
///

import Combine
import IWOHInteractionKit
@testable import IWOH

final class IntroductionRepositoryMock: IntroductionRepositoryTyp {
    init() { }
    init(locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never>) {
        self._locationAuthenticationStatus = locationAuthenticationStatus
    }

    var locationAuthenticationStatusSetCallCount = 0
    private var _locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never>!  { didSet { locationAuthenticationStatusSetCallCount += 1 } }
    var locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never> {
        get { return _locationAuthenticationStatus }
        set { _locationAuthenticationStatus = newValue }
    }

    var requestLocationAuthorizationCallCount = 0
    var requestLocationAuthorizationHandler: (() -> ())?
    func requestLocationAuthorization()  {
        requestLocationAuthorizationCallCount += 1
        if let requestLocationAuthorizationHandler = requestLocationAuthorizationHandler {
            requestLocationAuthorizationHandler()
        }
    }

	var requestNotificationAuthorizationCallCount = 0
	var requestNotificationAuthorizationHandler: (() -> ())?
	func requestNotificationAuthorization() {
		if let requestNotificationAuthorizationHandler = requestNotificationAuthorizationHandler {
			requestNotificationAuthorizationHandler()
		}
	}
}


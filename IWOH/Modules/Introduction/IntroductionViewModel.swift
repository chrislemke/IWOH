import Foundation
import Combine
import IWOHInteractionKit

final class IntroductionViewModel: ObservableObject {

	@Published var locationAuthenticationStatus: LocationAuthenticationStatus = .notDetermined
	@Published var isLocationServiceToggleTapped: Bool = false
	@Published var isNotificationRequestToggleTapped: Bool = false {
		didSet {
			repository.requestNotificationAuthorization()
		}
	}

	private var cancellableSet = Set<AnyCancellable>()
	private let repository: IntroductionRepositoryTyp

	init(repository: IntroductionRepositoryTyp) {
		self.repository = repository
		assignToIsLocationServiceActive(repository.locationAuthenticationStatus)
		sinkToIsLocationServiceToggleTapped(repository)
		assignToIsLocationServiceToggleTapped(repository.locationAuthenticationStatus)
	}

	func requestNotificationAuthorization() {
		repository.requestNotificationAuthorization()
	}

	// MARK: - private
	private func assignToIsLocationServiceToggleTapped(
		_ locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never>) {
			locationAuthenticationStatus
			.map {
				switch $0 {
					case .authorizedWhenInUse, .denied, .restricted:
						return true
					case .notDetermined:
						return false
				}
		}
		.receive(on: RunLoop.main)
		.assign(to: \.isLocationServiceToggleTapped, on: self)
		.store(in: &cancellableSet)

	}

	private func sinkToIsLocationServiceToggleTapped(_ repository: IntroductionRepositoryTyp) {
		$isLocationServiceToggleTapped
			.dropFirst() // To skip initilized value
			.delay(for: 1, scheduler: RunLoop.current)
			.sink { isOn in
				if isOn {
					repository.requestLocationAuthorization()
				}
		}
		.store(in: &cancellableSet)
	}

	private func assignToIsLocationServiceActive(
		_ locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never>) {
		locationAuthenticationStatus
			.receive(on: RunLoop.main)
			.assign(to: \.locationAuthenticationStatus, on: self)
			.store(in: &cancellableSet)
	}
}

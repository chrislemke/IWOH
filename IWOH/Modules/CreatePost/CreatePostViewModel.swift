import Foundation
import Combine
import IWOHInteractionKit
import Intents

enum WarningMessageState {
	case unspecified
	case noWarning
	case noMessage
	case messageToLong
	case noLocation
	case messageToLongNoLocation
	case noMessageNoLocation

	var text: String {
		switch self {
			case .noWarning, .unspecified:
				return "create.post.no.warning.text"
			case .noMessage:
				return "create.post.no.message.text"
			case .messageToLong:
				return "create.post.message.too.long.text"
			case .noLocation:
				return "create.post.no.location.text"
			case .messageToLongNoLocation:
				return "create.post.message.too.long.no.location.text"
			case .noMessageNoLocation:
				return "create.post.no.message.no.location.text"
		}
	}
}

final class CreatePostViewModel: ObservableObject {

	private var cancellableSet = Set<AnyCancellable>()
	private let repository: CreatePostRepositoryTyp

	// Output (to view)
	@Published var warningMessageState: WarningMessageState = .unspecified
	@Published var location: LocationManager.State = .unspecified
	@Published var submissionState: SubmissionState = .unspecified
	let createPostActivity = UserActivityManager.postActivity()

	var shortcut: INShortcut {
		let shortcut = INShortcut(intent: CreatePostIntent())!
		shortcut.intent?.suggestedInvocationPhrase = "Time to post"
		return shortcut
	}

	// Input (from view)
	@Published var postMessage: String?

	// MARK: - Lifecycle
	init(repository: CreatePostRepositoryTyp) {
		self.repository = repository
		assignToWarningMessageState($postMessage, repository.location, repository.locationAuthenticationStatus)
		assignToLocation(repository.location)
		repository.setLocationAccuracy(.best)
	}

	// MARK: - Public
	func requestLocation() {
		repository.requestLocation()
	}

	func sendPost() {
		requestLocation()
		Publishers.CombineLatest($postMessage, $location)
			.first()
			.map { message, locationState -> PostMessage? in
				guard let message = message else {
					return nil
				}
				switch locationState {
					case .error, .unspecified:
						logInfo("No coordinates available.")
						return nil
					case .location(let locationCoordinates):
						return PostMessage(message: message, location: locationCoordinates)
				}
		}
		.flatMap { [weak self]  postMessage -> AnyPublisher<SubmissionState, Never> in

			let errorPublisher = Just(SubmissionState.error(nil)).eraseToAnyPublisher()

			guard let postMessage = postMessage else {
				return errorPublisher
			}
			return self?.repository.submit(postMessage: postMessage) ?? errorPublisher
		}
		.eraseToAnyPublisher()
		.receive(on: RunLoop.main)
		.assign(to: \.submissionState, on: self)
		.store(in: &cancellableSet)
	}

	// MARK: - Private
	// swiftlint:disable:next function_body_length
	private func assignToWarningMessageState( _ postMessage: Published<String?>.Publisher,
											  _ location: AnyPublisher<LocationManager.State, Never>,
											  _ locationAuthenticationStatus: AnyPublisher<LocationAuthenticationStatus, Never>) {
		let messageNotEmptyPublisher = postMessage
			.map { message in
				message != "" && message != nil }
			.eraseToAnyPublisher()

		let messageNotTooLongPublisher = postMessage
			.map { message -> Bool in
				guard let message = message else {
					return true
				}
				return message.count <= maxMessageLength }
			.eraseToAnyPublisher()

		let coordinatesNotEmptyPublisher = location
			.map { locationCoordinates -> Bool in
				switch locationCoordinates {
					case .error, .unspecified:
						return false
					case .location:
						return true
				}
		}
		.eraseToAnyPublisher()

		Publishers
			.CombineLatest4(messageNotEmptyPublisher, coordinatesNotEmptyPublisher,
							messageNotTooLongPublisher, locationAuthenticationStatus)
			.map { messageNotEmpty, coordinatesNotEmpty, messageNotTooLong, locationAuthenticationStatus in
				if messageNotEmpty && coordinatesNotEmpty &&
					messageNotTooLong && locationAuthenticationStatus == .authorizedWhenInUse {
					return .noWarning
				} else if  messageNotEmpty && messageNotTooLong &&
					(coordinatesNotEmpty == false || locationAuthenticationStatus != .authorizedWhenInUse) {
					return .noLocation
				} else if messageNotEmpty == false && messageNotTooLong &&
					coordinatesNotEmpty && locationAuthenticationStatus == .authorizedWhenInUse {
					return .noMessage
				} else if messageNotEmpty && messageNotTooLong == false &&
					coordinatesNotEmpty && locationAuthenticationStatus == .authorizedWhenInUse {
					return .messageToLong
				} else if messageNotEmpty && messageNotTooLong == false &&
					(coordinatesNotEmpty == false || locationAuthenticationStatus != .authorizedWhenInUse) {
					return .messageToLongNoLocation
				}
				return .noMessageNoLocation
		}
		.eraseToAnyPublisher()
		.receive(on: RunLoop.main)
		.assign(to: \.warningMessageState, on: self)
		.store(in: &cancellableSet)
	}

	private func assignToLocation(_ currentLocation: AnyPublisher<LocationManager.State, Never>) {
		currentLocation
			.receive(on: RunLoop.main)
			.assign(to: \.location, on: self)
			.store(in: &cancellableSet)
	}

	deinit {
		repository.setLocationAccuracy(.tenMeters)
	}
}

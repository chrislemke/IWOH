import Intents
import Combine
import IWOHInteractionKit

final class CreatePostIntentHandler: NSObject, CreatePostIntentHandling {

	private var cancellableSet = Set<AnyCancellable>()
	private let firestoreManager = FirestoreManager()
	private let mlManager = MLManager()
	private let authenticationManager = AuthenticationManager()
	private var locationManager: LocationManager?

	override init() {
		super.init()
		OperationQueue.main.addOperation {
			self.locationManager = LocationManager()
		}
	}

	// MARK: - Public
	func handle(intent: CreatePostIntent, completion: @escaping (CreatePostIntentResponse) -> ()) {

		authenticationManager.configureAccessGroup()
		OperationQueue.main.addOperation { [weak self] in

			guard let self = self,
				let locationManager = self.locationManager,
				let message = intent.message else {
					completion(CreatePostIntentResponse(code: .failure, userActivity: nil))
					return
			}

			switch locationManager.location {
				case .error, .unspecified:
					completion(CreatePostIntentResponse(code: .failureNoLocation, userActivity: nil))
					return
				case .location(let location):

					self.mlManager.detectLanguage(for: message).map { languageCode in

						Post(message: message,
							 location: location,
							 heading: nil,
							 date: Date(),
							 languageCode: languageCode,
							 likes: 0, creatorID: self.authenticationManager.currentUserID ?? "")

					}.flatMap {  post in
						self.firestoreManager.add(FirestorePost(post: post))
					}.sink { submissionState in
						switch submissionState {
							case .error, .unspecified:
								completion(CreatePostIntentResponse(code: .failureSubmitting, userActivity: nil))
								return
							case .success:
								completion(CreatePostIntentResponse(code: .success, userActivity: nil))
						}
					}.store(in: &self.cancellableSet)
			}
			TrackingManager.track(.createPostIntentCTA)
		}
	}

	// swiftlint:disable:next line_length
	func resolveMessage(for intent: CreatePostIntent, with completion: @escaping (CreatePostMessageResolutionResult) -> ()) {

		guard let message = intent.message else {
			completion(CreatePostMessageResolutionResult.needsValue())
			return
		}

		if message.count > maxMessageLength {
			completion(CreatePostMessageResolutionResult.unsupported(forReason: .textToLong))
		} else if message.count == 0 {
			completion(CreatePostMessageResolutionResult.unsupported(forReason: .textToShort))
		}
		completion(CreatePostMessageResolutionResult.success(with: message))
	}
}

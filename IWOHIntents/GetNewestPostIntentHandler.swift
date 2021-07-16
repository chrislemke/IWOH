import Intents
import Combine
import IWOHInteractionKit

final class GetNewestPostIntentHandler: NSObject, GetNewestPostIntentHandling {

	private var cancellableSet = Set<AnyCancellable>()
	private let firestoreManager = FirestoreManager()
	private let authenticationManager = AuthenticationManager()
	
	func handle(intent: GetNewestPostIntent, completion: @escaping (GetNewestPostIntentResponse) -> ()) {
		let order = Order<FirestorePost>(field: .date, descending: true)
		let query = firestoreManager.simpleQuery(FirestorePost.self, order: order, limit: 1)

		firestoreManager.get(FirestorePost.self, query: query).sink { firestorePosts in
			guard let firestorePost = firestorePosts.first else {
				completion(GetNewestPostIntentResponse(code: .failure, userActivity: nil))
				return 
			}

			let userActivity = NSUserActivity(activityType:
				kNewestPostActivityType)
			userActivity.userInfo = [kPostID: firestorePost.id]

			let response = GetNewestPostIntentResponse(code: .success, userActivity: userActivity)
			response.message = firestorePost.message
			completion(response)
			TrackingManager.track(.newestIntentCTA)
		}.store(in: &cancellableSet)
	}

	func confirm(intent: GetNewestPostIntent, completion: @escaping (GetNewestPostIntentResponse) -> ()) {
		authenticationManager.configureAccessGroup()
		completion(GetNewestPostIntentResponse(code: .ready, userActivity: nil))
	}
}

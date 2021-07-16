import Foundation
import CoreSpotlight
import MobileCoreServices
import IWOHInteractionKit
import Combine

struct UserActivityManager {

	private let firestoreManager = FirestoreManager()

	static func postActivity() -> NSUserActivity {
		let activity = NSUserActivity(activityType: kCreatePostActivityType)
		activity.persistentIdentifier = NSUserActivityPersistentIdentifier(kCreatePostActivityType)

		activity.isEligibleForSearch = false
		activity.isEligibleForPrediction = false

		let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)

		activity.title = "Post to your location"
		attributes.contentDescription = "Let's hope somebody somewhere will read it."
		activity.suggestedInvocationPhrase = "Time to post"
		activity.contentAttributeSet = attributes
		activity.becomeCurrent()

		return activity
	}

	func post(for id: String) -> AnyPublisher<Post, Never> {
		return firestoreManager.get(FirestorePost.self, id: id)
			.map {
				Post(firestorePost: $0)
		}.eraseToAnyPublisher()
	}
}

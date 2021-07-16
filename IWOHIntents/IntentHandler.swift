import Intents
import Firebase

final class IntentHandler: INExtension {

	// MARK: - Public
    override func handler(for intent: INIntent) -> Any {
		configureFirebase()
		if intent is GetClosestPostIntent {
			return GetClosestPostIntentHandler()

		} else if intent is GetNewestPostIntent {
			return GetNewestPostIntentHandler()

		} else if intent is CreatePostIntent {
			return CreatePostIntentHandler()

		} else {
			fatalError("Unhandled intent!")
		}
    }

	// MARK: - Private
	private func configureFirebase() {
		FirebaseApp.configure()
		FirebaseConfiguration.shared.setLoggerLevel(.min)
	}
}

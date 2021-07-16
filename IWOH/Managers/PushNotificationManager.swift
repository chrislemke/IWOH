import UIKit
import Firebase
import Combine
import IWOHInteractionKit

final class PushNotificationManager: NSObject {

	private let application = UIApplication.shared
	private let userManager: UserManager
	fileprivate static let kPostID = "postID"

	init(userManager: UserManager) {
		self.userManager = userManager
		super.init()
		Messaging.messaging().delegate = self
	}

	func setDelegate(_ delegate: UNUserNotificationCenterDelegate) {
		UNUserNotificationCenter.current().delegate = delegate
	}

	func register() -> AnyPublisher<Bool, Error> {
		return Future<Bool, Error> { [weak self] promise in
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {authenticated, error in
					if let error = error {
						promise(.failure(error))
					} else {
						promise(.success(authenticated))
					}
			})
			self?.application.registerForRemoteNotifications()
		}.eraseToAnyPublisher()
	}
}

extension SceneDelegate: UNUserNotificationCenterDelegate {

	func application(application: UIApplication,
					 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		Messaging.messaging().apnsToken = deviceToken as Data
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {

		let userInfo = response.notification.request.content.userInfo
		if let postID = userInfo[PushNotificationManager.kPostID] as? String {
			self.openQuickInformation(postID)
		}
		completionHandler()
	}
}

extension PushNotificationManager: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		userManager.add(fcmToken: fcmToken)
	}
}

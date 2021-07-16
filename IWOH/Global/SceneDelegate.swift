import UIKit
import SwiftUI
import Foundation
import CoreSpotlight
import Combine
import IWOHInteractionKit

#if DEBUG
import FLEX
#endif

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	#if DEBUG
	var scene: UIWindowScene?
	#endif

	var window: UIWindow?
	private var cancellableSet = Set<AnyCancellable>()
	private let appViewState = Swinjector.shared.resolve(AppViewState.self)
	private let pushManager = Swinjector.shared.resolve(PushNotificationManager.self)

	// swiftlint:disable line_length
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

		let contentView = Swinjector.shared.resolve(RootContentView.self)

		if let windowScene = scene as? UIWindowScene {
			let window = UIWindow(windowScene: windowScene)
			window.rootViewController = UIHostingController(rootView: contentView.environmentObject(appViewState))
			self.window = window
			window.makeKeyAndVisible()

			pushManager.setDelegate(self)
			if UserDefaultsManager.hasSeenPushNotificationDialog {
				_ = pushManager.register()
			}

			#if DEBUG
			self.scene = windowScene
			NotificationCenter.default.addObserver(self,
												   selector: #selector(self.shakeNotificationReceived),
												   name: shakeNotification, object: nil)
			#endif

			if let userActivity = connectionOptions.userActivities.first {
				handle(userActivity: userActivity)
			}
		}
	}

	func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
		handle(userActivity: userActivity)
	}

	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		let userActivity: NSUserActivity
		if shortcutItem.type == "com.syhbl.iwoh.createpost" {
			userActivity = NSUserActivity(activityType: kCreatePostActivityType)
		} else {
			return
		}
		handle(userActivity: userActivity)
	}

	// MARK: - Public
	func openQuickInformation(_ postID: String) {
		let userActivityManager = UserActivityManager()
		self.appViewState.isQuickInformationPresented = false
		userActivityManager.post(for: postID).sink { [weak self] post in
			self?.appViewState.presentedPost = post
			self?.appViewState.isQuickInformationPresented = true
		}.store(in: &cancellableSet)
	}

	// MARK: - Private
	private func handle(userActivity: NSUserActivity) {
		if userActivity.activityType == CSSearchableItemActionType {
			if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
				openQuickInformation(uniqueIdentifier)
			}
		} else if userActivity.activityType == kCreatePostActivityType {
			self.appViewState.isCreatePostPresented = true
		} else if userActivity.activityType == kClosestPostActivityType ||
			userActivity.activityType == kNewestPostActivityType {
			if let id = userActivity.userInfo?[kPostID] as? String {
				openQuickInformation(id)
			}
		}
	}

	#if DEBUG
	@objc private func shakeNotificationReceived(_ notification: NSNotification) {
		guard let windowScene = self.scene else {
			return
		}
		FLEXManager.shared.showExplorer(from: windowScene)
	}
	#endif
}

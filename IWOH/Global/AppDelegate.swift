import UIKit
import Firebase

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	// swiftlint:disable line_length
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		setupServices()
		setupAppearance()
		return true
	}

	// MARK: - UISceneSession Lifecycle
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	// MARK: - Private
	private func setupServices() {
		FirebaseApp.configure()
		FirebaseConfiguration.shared.setLoggerLevel(.min)
	}

	private func setupAppearance() {
		UITableView.appearance().separatorStyle = .none
		UITableView.appearance().allowsSelection = false
		UITableView.appearance().backgroundColor = UIColor.clear
		UITableViewCell.appearance().selectionStyle = .none
	}
}

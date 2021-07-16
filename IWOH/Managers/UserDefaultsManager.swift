import Foundation

@propertyWrapper
struct UserDefault<TYP> {
	let key: String
	let defaultValue: TYP

	init(_ key: String, defaultValue: TYP) {
		self.key = key
		self.defaultValue = defaultValue
	}

	var wrappedValue: TYP {
		get {
			return UserDefaults.standard.object(forKey: key) as? TYP ?? defaultValue
		}
		set {
			UserDefaults.standard.set(newValue, forKey: key)
			UserDefaults.standard.synchronize()
		}
	}
}

struct UserDefaultsManager {

	private enum UserDafaultKey: String {
		case hasSeenAppIntroduction = "has_seen_app_introduction"
		case hasTappedAddToSiri = "has_tapped_add_to_siri"
		case hasSeenPushNotificationDialog = "has_seen_push_notification_dialog"
	}

	@UserDefault(UserDafaultKey.hasSeenAppIntroduction.rawValue, defaultValue: false)
	static var hasSeenAppIntroduction: Bool

	@UserDefault(UserDafaultKey.hasTappedAddToSiri.rawValue, defaultValue: false)
	static var hasTappedAddToSiri: Bool

	@UserDefault(UserDafaultKey.hasTappedAddToSiri.rawValue, defaultValue: false)
	static var hasSeenPushNotificationDialog: Bool
}

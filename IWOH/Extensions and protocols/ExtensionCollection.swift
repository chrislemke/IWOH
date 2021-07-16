import Foundation
import SwiftUI
import Combine

// Used so 'assign' does no create a retain cycle by capturing it's target strongly.
extension Publisher where Failure == Never {
	func assign<ROOT: AnyObject>(to keyPath: ReferenceWritableKeyPath<ROOT, Output>, on root: ROOT) -> AnyCancellable {
		sink { [weak root] in
			root?[keyPath: keyPath] = $0
		}
	}
}

extension String {
	var localized: String {
		let localizedString = NSLocalizedString(self, comment: "")
		if localizedString == self || localizedString == self.uppercased() {
			assertionFailure("Localized string for key \(self) was not found or is equal to the key!")
		}
		return localizedString
	}
}

extension LinearGradient {
	init(_ colors: Color...) {
		self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
	}
}

extension Binding {
	func didSet(execute: @escaping (Value) -> ()) -> Binding {
		return Binding(
			get: {
				return self.wrappedValue
		},
			set: {
				execute($0)
				self.wrappedValue = $0
		})
	}
}

extension UIWindow {
	open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			NotificationCenter.default.post(name: shakeNotification, object: nil)
		}
	}
}

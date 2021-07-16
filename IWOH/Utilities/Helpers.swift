import Foundation
import Combine
import SwiftUI
import IWOHInteractionKit

typealias PostMessage = (message: String, location: Location)
typealias Distance = (string: String, double: Double)

func delayInSeconds(_ seconds: Int, block: @escaping () -> ()) {
	DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds)) {
		block()
	}
}

func delayInMilliseconds(_ milliseconds: Int, block: @escaping () -> ()) {
	DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds)) {
		block()
	}
}

internal final class Inspection<VIEW> where VIEW: View {
	let notice = PassthroughSubject<UInt, Never>()
	var callbacks = [UInt: (VIEW) -> ()]()

	func visit(_ view: VIEW, _ line: UInt) {
		if let callback = callbacks.removeValue(forKey: line) {
			callback(view)
		}
	}
}

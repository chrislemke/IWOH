import UIKit
import SwiftUI
import Foundation
import IntentsUI

struct AddVoiceShortcutView: UIViewControllerRepresentable {

	let shortcut: INShortcut
	@Binding var isPresented: Bool

	func makeUIViewController(context: UIViewControllerRepresentableContext<AddVoiceShortcutView>)
		-> INUIAddVoiceShortcutViewController {
			let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
			viewController.delegate = context.coordinator
			return viewController
	}

	func updateUIViewController(_ uiViewController: INUIAddVoiceShortcutViewController, context: Context) {}

	func makeCoordinator() -> AddVoiceShortcutViewCoordinator {
		AddVoiceShortcutViewCoordinator($isPresented)
	}

	internal final class AddVoiceShortcutViewCoordinator: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
		var isPresented: Binding<Bool>

		init(_ isPresentend: Binding<Bool>) {
			self.isPresented = isPresentend
		}

		func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
											didFinishWith voiceShortcut: INVoiceShortcut?,
											error: Error?) {
			isPresented.wrappedValue = false
		}

		func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
			isPresented.wrappedValue = false
		}
	}
}

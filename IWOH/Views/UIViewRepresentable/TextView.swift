import SwiftUI
import UIKit
import IWOHInteractionKit

struct TextView: UIViewRepresentable {
    @Binding var text: String?
	var isFirstResponder = true

	// MARK: - UIViewRepresentable
    func makeUIView(context: UIViewRepresentableContext<TextView>) -> UITextView {

        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
		textView.textColor = UIColor.globalText
        textView.isScrollEnabled = false
		textView.returnKeyType = .done
		textView.backgroundColor = .clear
		textView.textContainer.maximumNumberOfLines = 8
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextView>) {

        if uiView.text != text {
            uiView.text = text
        }

		if isFirstResponder && context.coordinator.didBecomeFirstResponder == false {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }

	static func dismantleUIView(_ uiView: UITextView, coordinator: Coordinator) {
		uiView.delegate = nil
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(text: $text)
    }

	// MARK: - Coordinator
	internal final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String?>
		var didBecomeFirstResponder: Bool = false

		init(text: Binding<String?>) {
            self.text = text
        }

		// MARK: - UITextViewDelegate
        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
        }

		func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			if text == "\n" {
					textView.resignFirstResponder()
				return false
			}
			let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
			let numberOfChars = newText.count
			return numberOfChars < maxMessageLength + 5
		}
    }
}

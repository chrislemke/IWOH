import SwiftUI
import IWOHInteractionKit

struct IconLabelView: View {
	let text: String
	let imageTitle: String
	let color: Color

	var body: some View {
		HStack(alignment: .center, spacing: 3) {
			if text != "" {
				Image(systemName: imageTitle)
					.foregroundColor(color)
			}
			Text(LocalizedStringKey(text))
				.bold()
				.foregroundColor(color)
		}
	}
}

struct NonLocalizedIconLabelView: View {
	let text: String
	let imageTitle: String
	let color: Color

	var body: some View {
		HStack(alignment: .center, spacing: 3) {
			if text != "" {
				Image(systemName: imageTitle)
					.foregroundColor(color)
			}
			Text(text)
				.bold()
				.foregroundColor(color)
		}
	}
}

struct PostDetailInlayButtonView: View {
	let likeButtonAction: () -> ()
	let likes: UInt
	@Binding var translateToggleIsOn: Bool
	let translateToogleDisabled: Bool
	@Binding var likeButtonDisabled: Bool
	@Binding var shareButtonPressed: Bool
	var body: some View {
		HStack(alignment: .center, spacing: 30) {
			ShareButton(buttonPressed: $shareButtonPressed)
			TranslateToggle(toggleIsOn: $translateToggleIsOn, disabled: translateToogleDisabled)
			LikeButton(buttonAction: likeButtonAction, count: likes, disabled: $likeButtonDisabled)
		}
		.modifier(Inlayed())
	}
}

private struct ShareButton: View {
	@Binding var buttonPressed: Bool

	var body: some View {
		Button(action: {
			self.buttonPressed = true
			TrackingManager.track(.sharePostCTA)
		}, label: {
			Image(systemName: "square.and.arrow.up")
				.frame(width: 40, height: 40)
				.foregroundColor(.buttonImageEnabled)
		})
			.buttonStyle(FlatRectangleButtonStyle())
	}
}

private struct TranslateToggle: View {
	@Binding var toggleIsOn: Bool
	let disabled: Bool

	var body: some View {
		Toggle(isOn: $toggleIsOn
			.didSet(execute: { _ in TrackingManager.track(.translatePostCTA) })
		) {
			Image(systemName: "t.bubble")
				.frame(width: 40, height: 40)
				.foregroundColor( disabled ? .buttonImageDisabled : .buttonImageEnabled)
		}
		.toggleStyle(FlatRectangleToggleStyle())
		.disabled(disabled)
	}
}

private struct LikeButton: View {
	let buttonAction: () -> ()
	let count: UInt
	@Binding var disabled: Bool

	var body: some View {
		Button(action: {
			self.buttonAction()
			TrackingManager.track(.likePostCTA)
		}, label: {
			HStack {
				Image(systemName: "heart")
					.frame(width: 40, height: 40)
					.foregroundColor( disabled ? .buttonImageDisabled : .buttonImageEnabled)
				Text(String(count))
					.foregroundColor( disabled ? .buttonImageDisabled : .buttonImageEnabled)
					.padding(.trailing, 8)
			}
		})
			.buttonStyle(FlatRectangleButtonStyle())
			.disabled(disabled)
	}
}

struct PostMessageTextField: View {
	let message: String
	let padding: CGFloat
	var body: some View {
		VStack {
			Text(message)
				.animation(.easeIn)
				.foregroundColor(.globalText)
				.padding(padding)
				.frame(width: 250)
		}
	}
}

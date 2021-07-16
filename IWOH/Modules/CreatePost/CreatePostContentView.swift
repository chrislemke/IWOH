import SwiftUI
import Combine
import IWOHInteractionKit
import Intents

struct CreatePostContentView: Testable {

	let inspection = Inspection<Self>() // Needed for testing

	@ObservedObject var viewModel: CreatePostViewModel
	@EnvironmentObject private var appState: AppViewState
	@State private var addVoiceShortcutViewPresented: Bool = false

	var body: some View {
		NavigationView {
			ZStack {
				Color.globalBackground

				VStack(alignment: .center, spacing: vStackSpacing) {
					WarningLabel(text: viewModel.warningMessageState.text)
					MessageTextView(viewModel: viewModel)
					if DeviceManager.isSmallOrMediumDevice() == false &&
						UserDefaultsManager.hasTappedAddToSiri == false {
						AddToSiriButton($addVoiceShortcutViewPresented)
					}
					SubmitButton(viewModel: viewModel, buttonAction: submit)

					Spacer()
				}.padding(.top, topPadding)
			}.edgesIgnoringSafeArea(.all)
		}
		.sheet(isPresented: $addVoiceShortcutViewPresented, content: {
			AddVoiceShortcutView(shortcut: self.viewModel.shortcut,
								 isPresented: self.$addVoiceShortcutViewPresented)
				.edgesIgnoringSafeArea(.bottom)
		})
			.onReceive(inspection.notice) { self.inspection.visit(self, $0) }
			.onAppear {
				self.viewModel.requestLocation()
				TrackingManager.track(.create)
		}
		.onDisappear {
			self.viewModel.submissionState = .unspecified
		}
	}


	private func submit() {
		startHapticFeedback()
		viewModel.sendPost()
		TrackingManager.track(.submitPostCTA)
		delayInSeconds(1) {
			self.appState.isCreatePostPresented = false
			self.viewModel.postMessage = nil
		}
	}

	private var topPadding: CGFloat {
		if DeviceManager.isSmallDevice() {
			return 5
		} else if DeviceManager.isMediumDevice() {
			return 10
		}
		return 25
	}

	private var vStackSpacing: CGFloat {
		if DeviceManager.isSmallDevice() {
			return 5
		} else if DeviceManager.isMediumDevice() {
			return 5
		}
		return 15
	}

	func startHapticFeedback() {
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.success)
	}
}

private struct AddToSiriButton: View {
	var addVoiceShortcutViewPresented: Binding<Bool>

	init(_ addVoiceShortcutViewPresented: Binding<Bool>) {
		self.addVoiceShortcutViewPresented = addVoiceShortcutViewPresented
	}
	var body: some View {
		Button(action: {
			self.addVoiceShortcutViewPresented.wrappedValue = true
			UserDefaultsManager.hasTappedAddToSiri = true
		}, label: {
			Text("create.post.add.siri.button.title")
				.font(.system(size: 8))
				.foregroundColor(.globalText)

		})
	}
}

private struct MessageTextView: View {
	@ObservedObject var viewModel: CreatePostViewModel
	var body: some View {
		TextView(text: $viewModel.postMessage)
			.padding()
			.frame(width: 250, height: 250)
			.background(Color.globalFill)
			.cornerRadius(25)
			.shadow(color: .globalBottomShadow, radius: 10, x: 10, y: 10)
			.shadow(color: .globalTopShadow, radius: 10, x: -3, y: -3)
	}
}

private struct SubmitButton: View {
	@ObservedObject var viewModel: CreatePostViewModel
	let buttonAction: () -> ()

	var body: some View {
		Button(action: {
			self.buttonAction()
		}, label: {
			ButtonImage(submissionState: viewModel.submissionState, isActive: isActive)
		})
			.buttonStyle(SimpleCircleButtonStyle())
			.disabled(!isActive)
	}

	private var isActive: Bool {
		viewModel.warningMessageState == WarningMessageState.noWarning
	}

	private struct ButtonImage: View {
		var body: some View {
			Image(systemName: buttonState.imageName)
				.frame(width: 17, height: 12)
				.foregroundColor(buttonState.color)
		}

		let submissionState: SubmissionState
		let isActive: Bool
		private var buttonState: (imageName: String, color: Color) {
			switch submissionState {
				case .error:
					return ("xmark.octagon", .buttonImageEnabled)
				case .success:
					return ("checkmark", .green)
				case .unspecified:
					return ("paperplane", isActive ? .buttonImageEnabled : .buttonImageDisabled)
			}
		}
	}
}

struct WarningLabel: View {
	let text: String

	var body: some View {
		Text(LocalizedStringKey(text))
			.font(.system(size: 8))
			.foregroundColor(.globalText)
			.animation(.default)
	}
}

#if DEBUG
struct CreatePostContentView_Previews: PreviewProvider {
	static let viewModel = Swinjector.shared.resolve(CreatePostViewModel.self)
	static var previews: some View {
		CreatePostContentView(viewModel: Swinjector.shared.resolve(CreatePostViewModel.self))
			.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

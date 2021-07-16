import SwiftUI
import IWOHInteractionKit

struct CallOutView: View {
	@ObservedObject var viewModel: CalloutViewModel
	@State var angle: Double = 0
    @State private var translateToggleIsOn: Bool = false
	@State private var isSharePresented: Bool = false
    @Binding var isCallOutPresented: Bool

	var body: some View {
		VStack {
			LabelView(viewModel: viewModel)
			.padding(.top, 10)
			PostMessageTextField(
				message: translateToggleIsOn ? viewModel.translatedMessage : viewModel.originalMessage,
				padding: 20)
			PostDetailInlayButtonView(likeButtonAction: viewModel.likePost,
                                      likes: viewModel.likes,
                                      translateToggleIsOn: $translateToggleIsOn,
                                      translateToogleDisabled: !viewModel.shouldProvideTranslation,
									  likeButtonDisabled: $viewModel.likingDisabled,
									  shareButtonPressed: $isSharePresented)

			Image(systemName: "arrow.down.circle.fill")
				.foregroundColor(.buttonImageEnabled)
				.rotationEffect(.degrees(angle))
		}
		.sheet(isPresented: $isSharePresented, content: {
			ActivityView(activityItems: [self.viewModel.originalMessage], location: self.viewModel.location)
		})
		.onAppear {
			self.startHapticFeedback()
			withAnimation(Animation.easeIn.delay(0.7)) {
				self.angle = 180
				TrackingManager.track(.callOut)
			}
		}
		.padding(.top, 10)
		.padding(.horizontal, 10)
		.padding(.bottom, 20)
		.frame(maxWidth: 340)
		.background(Color.globalFill)
		.cornerRadius(25)
		.shadow(color: .globalBottomShadow, radius: 10, x: 10, y: 10)
		.shadow(color: .globalTopShadow, radius: 10, x: -3, y: -3)
	}

	func startHapticFeedback() {
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.success)
	}

	private struct LabelView: View {
		@ObservedObject var viewModel: CalloutViewModel
		var body: some View {
			HStack {
				NonLocalizedIconLabelView(text: viewModel.distance.string,
										  imageTitle: "mappin.circle",
										  color: .postDetailsIconLabel)
				NonLocalizedIconLabelView(text: viewModel.dateWithoutYear,
										  imageTitle: "calendar.circle",
										  color: .postDetailsIconLabel)
			}
		}
	}
}

#if DEBUG
struct MapCallOutView_Previews: PreviewProvider {
	static var previews: some View {
		CallOutView(viewModel: Preview.postCalloutViewModel, isCallOutPresented: Binding.constant(true))
		.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

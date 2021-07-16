import SwiftUI
import IWOHInteractionKit

struct PostInformationContentView: View {
	@EnvironmentObject private var appViewState: AppViewState
	@ObservedObject var viewModel: PostInformationViewModel

	var body: some View {
		ZStack {
			VStack {
				mapView
					.padding(.bottom, -57)

				PostInformationView(viewModel: viewModel)
					.background(Color.globalFill)
					.cornerRadius(25)
					.shadow(radius: 10)
					.layoutPriority(1)
			}
			// To remove the small rounded corners of the 'PostInformationView'
			.padding(.bottom, DeviceManager.isSmallOrMediumDevice() ? -10 : 0)
			.edgesIgnoringSafeArea(.all)

			VStack {
				HStack {
					Spacer()
					CloseButton()
						.padding(.trailing)
						.padding(.top)
				}
				Spacer()
			}
		}
		.onAppear {
				self.appViewState.isPostInformationPresented = true
				self.appViewState.presentedPost = self.viewModel.post
				TrackingManager.track(.information)
		}.onDisappear {
			self.resetViewState()
		}
	}

	private var mapView: some View {
		MapView(viewModel: MapViewModelConverter.viewModel(from: viewModel),
				selectedAnnotation: Binding.constant(nil),
				isCallOutPresented: Binding.constant(false),
				annotations: Binding.constant([PostAnnotation(post: viewModel.post, active: false)])
				)
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   maxHeight: .infinity,
				   alignment: .center)
			.listRowInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
	}

	private func resetViewState() {
		self.appViewState.isPostInformationPresented = false
		self.appViewState.presentedPost = nil
		self.appViewState.quickInformationSheet = .none
	}
}

private struct CloseButton: View {
	@Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

	var body: some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}, label: {
			Image(systemName: "xmark")
				.foregroundColor(.buttonImageEnabled)
		})
			.buttonStyle(SimpleCircleButtonStyle())
	}
}

#if DEBUG
struct PostDetailsContentView_Previews: PreviewProvider {
	static var previews: some View {
		PostInformationContentView(viewModel: Preview.postInformationViewModel).environmentObject(AppViewState())
		.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

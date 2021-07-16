import SwiftUI
import IWOHInteractionKit

struct PostsARContentView: View {
	@EnvironmentObject var appViewState: AppViewState
	@ObservedObject var viewModel: PostsARViewModel
	@State private var selectedAnnotation: AnnotationTyp?
	@State private var isCallOutPresented = false
	@State private var draggedOffset = CGSize.zero

	var body: some View {
		ZStack {
			VStack {
				ARView(annotationViewModels: $viewModel.annotationViewModels,
					   selectedAnnotation: self.$selectedAnnotation,
					   isCallOutPresented: self.$isCallOutPresented)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.globalBackground)
			.cornerRadius(25)
			.shadow(color: .gray, radius: 8, x: -3, y: -3)
			CloseButton()
			callOut
		}
		.onAppear {
			TrackingManager.track(.ar)
		}
	}

	private var callOut: some View {
		Group {
			if isCallOutPresented && selectedAnnotation != nil {
				Swinjector.shared.resolve(CallOutView.self,
										  argument: selectedAnnotation!.post, $isCallOutPresented)
					.offset(y: draggedOffset.height)
					.transition(.move(edge: .top))
					.gesture(DragGesture()
						.onChanged { value in
							if value.translation.height > 0 {
								self.draggedOffset = CGSize.zero
								return
							}
							self.draggedOffset = value.translation
					}
					.onEnded { _ in
						if abs(self.draggedOffset.height) > 150 {
							self.isCallOutPresented = false
						}
						self.draggedOffset = CGSize.zero
					})
			}
		}
	}
}

private struct CloseButton: View {
	@EnvironmentObject var appViewState: AppViewState
	var body: some View {
		VStack(alignment: .center) {
			Spacer()
			Button(action: {
				self.$appViewState.isARViewPresented.animation(Animation.easeInOut).wrappedValue = false
			}, label: {
				Image(systemName: "xmark")
					.foregroundColor(.buttonImageEnabled)
			})
				.buttonStyle(SimpleCircleButtonStyle())
		}
		.padding(.bottom, 70)
	}
}

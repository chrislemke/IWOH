import SwiftUI
import MapKit
import IWOHInteractionKit
import Intents

struct PostsMapContentView: View {

	@ObservedObject var viewModel: PostsMapViewModel
	@State private var selectedAnnotation: AnnotationTyp?
	@State private var isCallOutPresented = false
	@State private var draggedOffset = CGSize.zero

	var body: some View {
		ZStack {
			mapView
			callOut
		}
		.edgesIgnoringSafeArea(.vertical)
		.onAppear {
			self.viewModel.startUpdatingLocation()
			TrackingManager.track(.map)
		}
		.onDisappear {
			self.viewModel.stopUpdatingLocation()
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


	private var mapView: some View {
		MapView(viewModel: MapViewModelConverter.viewModel(from: viewModel),
				selectedAnnotation: $selectedAnnotation,
				isCallOutPresented: $isCallOutPresented,
				annotations: $viewModel.annotations)
			.frame(maxWidth: .infinity,
				   maxHeight: .infinity,
				   alignment: .topLeading)
			.listRowInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
			.edgesIgnoringSafeArea(.top)
	}
}


#if DEBUG
struct PostsMapContentView_Previews: PreviewProvider {
	static var previews: some View {
		Swinjector.shared.resolve(PostsMapContentView.self)
			.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

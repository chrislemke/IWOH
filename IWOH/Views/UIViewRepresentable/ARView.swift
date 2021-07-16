import ARKit_CoreLocation
import UIKit
import SwiftUI
import CoreLocation
import SceneKit
import IWOHInteractionKit

final class PostARAnnotation: LocationAnnotationNode, AnnotationTyp {
	let post: Post
	
	// MARK: - Lifecycle
	init(viewModel: PostARAnnotationViewModel) {
		self.post = viewModel.post
		let coordinate = CLLocationCoordinate2D(latitude: viewModel.location.latitude,
												longitude: viewModel.location.longitude)
		let location = CLLocation(coordinate: coordinate, altitude: viewModel.location.altitude)
		super.init(location: location, image: PostARAnnotation.image(from: viewModel))
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private
	static private func image(from viewModel: PostARAnnotationViewModel) -> UIImage {
		let view = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 40))
		view.clipsToBounds = true
		view.layer.cornerRadius = 8
		view.backgroundColor = UIColor.globalBackground
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.annotationForeground!.cgColor
		view.text = viewModel.distance
		view.textAlignment = .center
		view.tintColor = .annotationForeground
		return view.image
	}
}

struct ARView: UIViewRepresentable {

	@Binding var annotationViewModels: [PostARAnnotationViewModel]
	@Binding var selectedAnnotation: AnnotationTyp?
	@Binding var isCallOutPresented: Bool

	func makeUIView(context: Context) -> SceneLocationView {
		let view = SceneLocationView(trackingType: .orientationTracking)
		setup(view: view, context: context)
		view.run()

		if DeviceManager.isSimulator() {
			logWarning("AR feature is not suported by the simulator!")
		}

		return view
	}

	func updateUIView(_ view: SceneLocationView, context: Context) {
		let annotationNodes = annotationViewModels.map { viewModel in
			PostARAnnotation(viewModel: viewModel)
		}

		view.addLocationNodesWithConfirmedLocation(locationNodes: annotationNodes)

	}

	static func dismantleUIView(_ uiView: SceneLocationView, coordinator: ARViewCoordinator) {
		uiView.pause()
	}

	private func setup(view: SceneLocationView, context: Context) {
		view.locationNodeTouchDelegate = context.coordinator
		view.locationEstimateMethod = .mostRelevantEstimate
	}

	func makeCoordinator() -> ARViewCoordinator {
		Coordinator(self)
	}

	internal final class ARViewCoordinator: NSObject, LNTouchDelegate {
		let view: ARView

		init(_ view: ARView) {
			self.view = view
		}

		func annotationNodeTouched(node: AnnotationNode) {
			guard let annotation = node.parent as? PostARAnnotation else {
				return
			}

			withAnimation {
				self.view.isCallOutPresented = true
				self.view.selectedAnnotation = annotation
				TrackingManager.track(.arCallOutOpened)
			}
		}

		func locationNodeTouched(node: LocationNode) {}
	}
}

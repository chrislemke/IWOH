import SwiftUI
import MapKit
import Combine
import IWOHInteractionKit

final class PostAnnotation: NSObject, MKAnnotation, AnnotationTyp {

	@objc dynamic var coordinate: CLLocationCoordinate2D
	let title: String?
	let subtitle: String?
	let post: Post

	init(post: Post, active: Bool) {
		self.coordinate = CLLocationCoordinate2D(latitude: post.location.latitude,
												 longitude: post.location.longitude)
		self.post = post
		if active {
			self.title = post.date.dateWithYear()
		} else {
			self.title = ""
		}
		self.subtitle = post.message
	}
}

// MARK: - MapViewModel
struct MapViewModel {
	init(location: LocationManager.State,
		 span: CoordinateSpan,
		 locationTopInset: Double = 0) {
		self.location = location
		self.span = span
		self.locationTopInset = CGFloat(locationTopInset)
	}

	let location: LocationManager.State
	let span: CoordinateSpan
	let locationTopInset: CGFloat
}

struct MapView: UIViewRepresentable {

	var viewModel: MapViewModel
	@Binding var selectedAnnotation: AnnotationTyp?
	@Binding var isCallOutPresented: Bool
	@Binding var annotations: [PostAnnotation]

	// MARK: - Public
	func updateUIView(_ view: MKMapView, context: Context) {
		view.addAnnotations(annotations)
	}

	// MARK: - UIViewRepresentable
	func makeUIView(context: Context) -> MKMapView {
		let view = MKMapView(frame: .zero)
		setupMap(view: view, context: context)

		view.region.span = MKCoordinateSpan(latitudeDelta: viewModel.span.longitudeDelta,
											longitudeDelta: viewModel.span.longitudeDelta)
		setVisibleMap(view)
		view.addAnnotations(annotations)
		return view
	}

	static func dismantleUIView(_ uiView: MKMapView, coordinator: MapViewCoordinator) {
		uiView.removeAnnotations(uiView.annotations)
		uiView.delegate = nil
	}

	func makeCoordinator() -> MapViewCoordinator {
		Coordinator(self)
	}

	// MARK: - Private
	private func setupMap(view: MKMapView, context: Context) {
		view.delegate = context.coordinator
		view.showsBuildings = true
		view.showsCompass = false
		view.showsScale = false
		view.mapType = .standard
		view.showsUserLocation = true
		view.tintColor = .locationIndicator
		view.register(MKMarkerAnnotationView.self,
					  forAnnotationViewWithReuseIdentifier: NSStringFromClass(PostAnnotation.self))
	}

	private func setVisibleMap(_ view: MKMapView) {
		switch viewModel.location {
			case .unspecified, .error:
				logInfo("Could not set location.")
			case .location(let location):
				let coordinates = CLLocationCoordinate2D(latitude: location.latitude,
														 longitude: location.longitude)

				let span = MKCoordinateSpan(latitudeDelta: viewModel.span.latitudeDelta,
											longitudeDelta: viewModel.span.longitudeDelta)

				let region = MKCoordinateRegion(center: coordinates, span: span)
				view.setVisibleMapRect(MKMapRectForCoordinateRegion(region: region),
									   edgePadding: UIEdgeInsets(top: viewModel.locationTopInset, left: 0.0, bottom: 0.0, right: 0.0),
									   animated: false)
		}
	}

	private func updateCenterCoordinate(on view: MKMapView) {
		if CLLocationCoordinate2DIsValid(view.userLocation.coordinate) {
			view.setCenter(view.userLocation.coordinate, animated: false)
		}
	}

	private func MKMapRectForCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect {
		let a = MKMapPoint(CLLocationCoordinate2DMake(
			region.center.latitude + region.span.latitudeDelta / 2,
			region.center.longitude - region.span.longitudeDelta / 2))
		let b = MKMapPoint(CLLocationCoordinate2DMake(
			region.center.latitude - region.span.latitudeDelta / 2,
			region.center.longitude + region.span.longitudeDelta / 2))
		return MKMapRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(a.x-b.x), height: abs(a.y-b.y))
	}
}

internal final class MapViewCoordinator: NSObject, MKMapViewDelegate {
	let mapView: MapView

	init(_ mapView: MapView) {
		self.mapView = mapView
	}

	// MARK: - Private
	private func postAnnotationView(for annotation: PostAnnotation, on mapView: MKMapView) -> MKAnnotationView {
		let identifier = NSStringFromClass(PostAnnotation.self)
		var annotationView: MKMarkerAnnotationView?

		if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
			as? MKMarkerAnnotationView {
			annotationView = dequeuedAnnotationView
		} else {
			annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
		}
		annotationView?.animatesWhenAdded = false
		annotationView?.canShowCallout = true
		annotationView?.markerTintColor = .annotationView
		annotationView?.glyphTintColor = .annotationGlyph
		annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

		return annotationView ?? MKMarkerAnnotationView()
	}

	// MARK: - MKMapViewDelegate
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? PostAnnotation else {
			return nil
		}
		return postAnnotationView(for: annotation, on: mapView)
	}

	func mapView(_ mapView: MKMapView,
				 annotationView view: MKAnnotationView,
				 calloutAccessoryControlTapped control: UIControl) {

		guard let annotation = view.annotation as? PostAnnotation else {
			return
		}
		withAnimation {
			self.mapView.isCallOutPresented = true
			self.mapView.selectedAnnotation = annotation
			TrackingManager.track(.mapCallOutOpened)
		}
	}
}

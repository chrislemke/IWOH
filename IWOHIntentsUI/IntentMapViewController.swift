import IntentsUI
import MapKit
import IWOHInteractionKit
import Combine
import Firebase

private final class Annotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D

	init(latitude: Double, longitude: Double) {
		self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}

final class IntentMapViewController: UIViewController, INUIHostedViewControlling {

	@IBOutlet var mapView: MKMapView!
	@IBOutlet var messageLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	private var cancellableSet = Set<AnyCancellable>()

	// MARK: - Public
	func configureView(for parameters: Set<INParameter>,
					   of interaction: INInteraction,
					   interactiveBehavior: INUIInteractiveBehavior,
					   context: INUIHostedViewContext,
					   completion: @escaping (Bool, Set<INParameter>, CGSize) -> ()) {

		guard let response = interaction.intentResponse as? GetClosestPostIntentResponse,
			let userPlacemark = response.userLocation,
			let userLocation = userPlacemark.location,
			let annotationPlacemark = response.annotationLocation,
			let annotationLocation = annotationPlacemark.location else {
				completion(false, parameters, desiredSize)
				return
		}
		let annotation = Annotation(latitude: annotationLocation.coordinate.latitude,
									longitude: annotationLocation.coordinate.longitude)
		
		messageLabel.text = response.message
		dateLabel.text = response.date
		setupMapView(mapView: mapView, userLocation: userLocation)
		mapView.addAnnotation(annotation)
		completion(true, parameters, desiredSize)
	}

	var desiredSize: CGSize {
		return CGSize(width: 320, height: 380)
	}

	// MARK: - Private
	private func setupMapView(mapView: MKMapView, userLocation: CLLocation) {
		OperationQueue.main.addOperation {
			mapView.showsBuildings = true
			mapView.showsCompass = false
			mapView.showsScale = false
			mapView.mapType = .standard
			mapView.showsUserLocation = true
			mapView.tintColor = .locationIndicator
			mapView.register(MKMarkerAnnotationView.self,
							 forAnnotationViewWithReuseIdentifier: NSStringFromClass(Annotation.self))

			mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.006,
												   longitudeDelta: 0.006)

			mapView.centerCoordinate.latitude = userLocation.coordinate.latitude
			mapView.centerCoordinate.longitude = userLocation.coordinate.longitude
		}
	}
}

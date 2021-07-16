import Foundation
import IWOHInteractionKit

struct MapViewModelConverter {

	// Used by 'PostsMap'
	static func viewModel(from viewModel: PostsMapViewModel) -> MapViewModel {
		MapViewModel(location: viewModel.location,
					 span: viewModel.locationSpan)
	}

	// Used by 'PostInformation'
	static func viewModel(from viewModel: PostInformationViewModel) -> MapViewModel {
		MapViewModel(location: LocationManager.State.location(viewModel.location),
					 span: viewModel.mapSpan ?? CoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
	}
}

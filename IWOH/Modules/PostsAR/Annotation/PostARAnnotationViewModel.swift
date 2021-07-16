import Foundation
import IWOHInteractionKit

final class PostARAnnotationViewModel: ObservableObject {

	var location: Location {
		post.location
	}

	var dateWithoutYear: String {
		post.date.dateWithoutYear()
	}

	var distance: String {
		currentLocationDistanceString(from: post.location).string
	}
	private let repository: PostARAnnotationRepository
	let post: Post

	// MARK: - Lifecylce
	init(post: Post, repository: PostARAnnotationRepository) {
		self.repository = repository
		self.post = post
	}

	// MARK: - Private
	private func currentLocationDistanceString(from location: Location) -> Distance {
		guard let distanceDouble = repository.distance(from: location) else {
			return ("distance.somewhere.text".localized, -1)
		}
		switch distanceDouble {
			case 0..<11:
				return ("distance.nearby.text".localized, distanceDouble)
			case 11..<1000:
				return ("\(Int(distanceDouble)) \("distane.m.text".localized)", distanceDouble)
			case 1000..<100001:
				return ("\(String(format: "%.1f", distanceDouble / 1000)) \("distance.km.text".localized)", distanceDouble)
			case 100001...: // up to 400 km
				return ("distance.far.away.text".localized, distanceDouble)
			default:
				return ("distance.somewhere.text".localized, -1)
		}
	}
}

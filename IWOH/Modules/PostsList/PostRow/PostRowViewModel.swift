import Foundation
import Combine
import IWOHInteractionKit

final class PostRowViewModel: ObservableObject, Identifiable, Equatable {

	@Published var distance: Distance = ("", -1)

	var id: UUID {
		post.id
	}
	var originalMessage: String {
		post.message
	}

	var dateWithYear: String {
		post.date.dateWithYear()
	}

	var dateWithoutYear: String {
		post.date.dateWithYear()
	}

	var date: Date {
		post.date
	}

	let post: Post

	private var cancellableSet = Set<AnyCancellable>()
	private let repository = Swinjector.shared.resolve(PostRowRepository.self)

	private var systemLanguageCode: String {
		guard let languageCode = Locale.preferredLanguages.first else {
			logError("Could not retrieve 'preferredLanguages' code!")
			return "language.code".localized
		}
		return String(languageCode.prefix(2))
	}

	// MARK: - Lifecycle
	init(post: Post) {
		self.post = post
		distance = currentLocationDistanceString(from: post.location)
		assignToDistance(repository.location())
	}

	// MARK: - Equatable
	static func == (lhs: PostRowViewModel, rhs: PostRowViewModel) -> Bool {
		lhs.id == rhs.id
	}

	// MARK: - Private
	private func assignToDistance(_ location: AnyPublisher<LocationManager.State, Never>) {
		location
			.map { _ in
				self.currentLocationDistanceString(from: self.post.location)
		}
		.receive(on: RunLoop.main)
		.assign(to: \.distance, on: self)
		.store(in: &cancellableSet)
	}

	private func currentLocationDistanceString(from location: Location) -> Distance {
		guard let distanceDouble = repository.distance(from: location) else {
			return ("distance.somewhere.text".localized, -1)
		}
		switch distanceDouble {
			case 0..<11:
				return ("distance.nearby.text".localized, distanceDouble)
			case 11..<1000:
				return ("\(Int(distanceDouble)) \("distane.m.away.text".localized)", distanceDouble)
			case 1000..<100001:
				return ("\(String(format: "%.1f", distanceDouble / 1000)) \("distance.km.away.text".localized)", distanceDouble)
			case 100001..<400001: // up to 400 km
				return ("distance.far.away.text".localized, distanceDouble)
			case 400001..<1000001: // up to 1000 km
				return ("distance.very.far.away.text".localized, distanceDouble)
			case 1000001..<4000001: // up to 4000 km
				return ("distance.extremely.far.away.text".localized, distanceDouble)
			case 4000001...: // everything above  4000 km
				return ("distance.still.on.the.planet.text".localized, distanceDouble)
			default:
				return ("distance.somewhere.text".localized, -1)
		}
	}
}

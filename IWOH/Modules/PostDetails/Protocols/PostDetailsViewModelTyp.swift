import Foundation
import Combine
import IWOHInteractionKit

struct PostDetailsViewModelComponents {
	fileprivate let repository: PostDetailsRepositoryTyp
	fileprivate var cancellableSet = Set<AnyCancellable>()

	init(repository: PostDetailsRepositoryTyp) {
		self.repository = repository
	}
}

/// @mockable
protocol PostDetailsViewModelTyp: ObservableObject {

	var location: Location { get set }
	var likes: UInt { get set }
	var likingDisabled: Bool { get set }
	var distance: Distance { get set }

	var originalMessage: String { get }
	var translatedMessage: String { get }
	var shouldProvideTranslation: Bool { get }
	var systemLanguageCode: String { get }

	var post: Post { get }
	var components: PostDetailsViewModelComponents { get set }

	func likePost()
	func assignToLikes()
	func assignToLikedByUser(_ canLikePost: AnyPublisher<Bool, Never>)
	func currentLocationDistanceString(from location: Location) -> Distance
}

extension PostDetailsViewModelTyp {

	var originalMessage: String {
		post.message
	}

	var translatedMessage: String {
		guard let translated = post.translated,
			let translatedMessage = translated[String(systemLanguageCode.prefix(2))] else {
				return post.message
		}
		return translatedMessage
	}

	var shouldProvideTranslation: Bool {
		(post.languageCode != systemLanguageCode) && (post.languageCode != "")
	}

	var systemLanguageCode: String {
		guard let languageCode = Locale.preferredLanguages.first else {
			logError("Could not retrieve 'preferredLanguages' code!")
			return "language.code".localized
		}
		return String(languageCode.prefix(2))
	}

	func likePost() {
		_ = components.repository.likePost(post)
	}

	func assignToLikes() {
		components.repository.likes(for: post)
			.receive(on: RunLoop.main)
			.assign(to: \.likes, on: self)
			.store(in: &components.cancellableSet)
	}

	func assignToLikedByUser(_ canLikePost: AnyPublisher<Bool, Never>) {
		canLikePost
			.map { !$0 }
			.receive(on: RunLoop.main)
			.assign(to: \.likingDisabled, on: self)
			.store(in: &components.cancellableSet)
	}

	func currentLocationDistanceString(from location: Location) -> Distance {
		guard let distanceDouble = components.repository.distance(from: location) else {
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

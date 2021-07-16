import Combine
import IWOHInteractionKit

final class PostInformationViewModel: PostDetailsViewModelTyp {

	@Published var mapSpan: CoordinateSpan?
	@Published var location: Location
	@Published var likes: UInt = 0
	@Published var likingDisabled: Bool = true
	@Published var distance: Distance = ("", -1)

	var dateWithYear: String {
		post.date.dateWithYear()
	}

	let post: Post
	var components: PostDetailsViewModelComponents
	private let repository: PostDetailsRepositoryTyp

	// MARK: - Lifecylce
	init(post: Post, repository: PostDetailsRepositoryTyp) {
		self.post = post
		self.repository = repository
		self.location = post.location
		self.components = PostDetailsViewModelComponents(repository: repository)
		likes = post.likes
		distance = currentLocationDistanceString(from: post.location)
		mapSpan = spanFromDistance(from: post.location)
		assignToLikedByUser(repository.canLikePost(post))
	}

	// MARK: - Private
	private func spanFromDistance(from location: Location) -> CoordinateSpan? {
		guard let distance = repository.currentLocationDistance(location: location) else {
				return nil
		}
		// Span to show user location ans annotation location on map
		let span = min(distance / 45000, 20)
		return CoordinateSpan(latitudeDelta: span, longitudeDelta: span)
	}
}

import Combine
import IWOHInteractionKit

final class CalloutViewModel: PostDetailsViewModelTyp {

	@Published var location: Location
	@Published var likes: UInt = 0
	@Published var likingDisabled: Bool = true
	@Published var distance: Distance = ("", -1)

	var dateWithoutYear: String {
		post.date.dateWithoutYear()
	}

	let post: Post
	var components: PostDetailsViewModelComponents

	// MARK: - Lifecylce
	init(post: Post, repository: PostDetailsRepositoryTyp) {
		self.post = post
		self.location = post.location
		self.components = PostDetailsViewModelComponents(repository: repository)
		likes = post.likes
		distance = currentLocationDistanceString(from: post.location)
		assignToLikedByUser(repository.canLikePost(post))
		assignToLikes()
	}
}

import Foundation
import Combine
import IWOHInteractionKit

final class PostsListViewModel: ObservableObject {

	@Published var postRowViewModels = [PostRowViewModel]()
	@Published var closestPostDistance: String = ""
	@Published var closestPost: PostRowViewModel?
	@Published var newestPost: PostRowViewModel?

	private var cancellableSet = Set<AnyCancellable>()
	private let repository: PostsListRepository

	init(repository: PostsListRepository) {
		self.repository = repository
		assignToPostRowViewModels(repository.posts, repository.location())
		assignToClosestPost($postRowViewModels, repository.location())
		assignToNewestPost($postRowViewModels)
	}

	func requestLocation() {
		repository.requestLocation()
	}

	// MARK: - Private
	private func assignToClosestPost(_ postRowViewModels: Published<[PostRowViewModel]>.Publisher,
									 _ location: AnyPublisher<LocationManager.State, Never>) {
		// swiftlint:disable:next line_length
		Publishers.CombineLatest(postRowViewModels, location) // 'location' is used so it get's trigged when the location is changing.
			.compactMap { (postsViewModels, _) in
				postsViewModels.filter { $0.distance.double >= 0 }
					.min { (first, second) -> Bool in
						first.distance.double < second.distance.double // Return the closest postViewModel. Compared by distance.
				}
		}
		.receive(on: RunLoop.main)
		.assign(to: \.closestPost, on: self)
		.store(in: &cancellableSet)
	}

	private func assignToNewestPost(_ postRowViewModels: Published<[PostRowViewModel]>.Publisher) {
		postRowViewModels
			.map {
				$0.max { (first, second) -> Bool in
					first.date < second.date
				}
		}
		.receive(on: RunLoop.main)
		.assign(to: \.newestPost, on: self)
		.store(in: &cancellableSet)
	}

	private func assignToPostRowViewModels(_ posts: AnyPublisher<[Post], Never>,
										   _ location: AnyPublisher<LocationManager.State, Never>) {

		Publishers.CombineLatest(posts, location)
			.map { $0.0.compactMap { PostRowViewModel(post: $0) }
		}
		.receive(on: RunLoop.main)
		.assign(to: \.postRowViewModels, on: self)
		.store(in: &cancellableSet)
	}
}

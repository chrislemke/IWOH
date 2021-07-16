import Foundation
import Combine
import IWOHInteractionKit

final class PostsMapViewModel: ObservableObject {

	private var cancellableSet = Set<AnyCancellable>()
	private var repository: PostsMapRepositoryTyp

	@Published var location: LocationManager.State = .unspecified
	@Published var locationSpan = CoordinateSpan(latitudeDelta: 0.002,
												 longitudeDelta: 0.002)
	@Published var annotations = [PostAnnotation]()

	// MARK: - Lifecycle
	init(repository: PostsMapRepositoryTyp) {
		self.repository = repository
		self.location = repository.location
		assignToPostAnnotation(repository)
	}

	// MARK: - Public
	func startUpdatingLocation() {
		repository.startUpdatingLocation()
	}

	func stopUpdatingLocation() {
		repository.stopUpdatingLocation()
	}

	// MARK: - Private
	private func assignToPostAnnotation(_ repository: PostsMapRepositoryTyp) {
		Publishers.CombineLatest(repository.posts, repository.currentLocation)
			.map { $0.0 }
			.map {
				$0.map { post in
					return PostAnnotation(post: post, active: true)
				}
			}
			.eraseToAnyPublisher()
			.receive(on: RunLoop.main)
			.assign(to: \.annotations, on: self)
			.store(in: &cancellableSet)
	}
}

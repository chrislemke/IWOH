import Foundation
import Combine
import IWOHInteractionKit

final class PostsARViewModel: ObservableObject {

	@Published var annotationViewModels = [PostARAnnotationViewModel]()
	private var cancellableSet = Set<AnyCancellable>()

	init(repository: PostARRepositoryTyp) {
		assignToAnnotationViewModels(repository.posts)
	}

	private func assignToAnnotationViewModels(_ posts: AnyPublisher<[Post], Never>) {
		posts
			.map { $0.map {
					Swinjector.shared.resolve(PostARAnnotationViewModel.self, argument: $0)
				}
			}
		.receive(on: RunLoop.main)
		.assign(to: \.annotationViewModels, on: self)
		.store(in: &cancellableSet)
	}
}

import Combine
import IWOHInteractionKit

/// @mockable
protocol PostARRepositoryTyp {

	var posts: AnyPublisher<[Post], Never> { get }
}

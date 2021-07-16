import Combine
import IWOHInteractionKit

/// @mockable
protocol PostDetailsRepositoryTyp {

	func currentLocationDistance(location: Location) -> Double?
	func canLikePost(_ post: Post) -> AnyPublisher<Bool, Never>
	func likePost(_ post: Post) -> AnyPublisher<Bool, Never>
	func likes(for post: Post) -> AnyPublisher<UInt, Never>
	func distance(from location: Location) -> Double?
}

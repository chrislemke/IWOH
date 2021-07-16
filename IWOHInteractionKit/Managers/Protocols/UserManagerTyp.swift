import Combine

/// @mockable
public protocol UserManagerTyp {

	func add(fcmToken: String)
	func likePost(_ postID: String) -> AnyPublisher<Bool, Never>
	func addLikeToUser(_ postID: String) -> AnyPublisher<Bool, Never>
	func isLikedByUser(_ postID: String) -> AnyPublisher<Bool, Never>
	func isCreatedByUser(_ post: Post) -> AnyPublisher<Bool, Never>
}

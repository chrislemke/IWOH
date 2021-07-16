/// Shared membership

import Foundation

public struct FirestoreUser: Encodable, Storeable {

	public let id: String
	public let lastLogin: Date

	public init(user: User) {
		self.id = user.id
		self.lastLogin = user.lastLogin
	}
}

extension FirestoreUser: Subcollectable {

	public typealias SubcollectionPath = Subcollection
	public typealias CollectionFields = Fields

	public static let collectionPath = "users"

	public enum Fields: String {
		case id
		case fcmToken
	}

	public enum Subcollection: String {
		case createdPosts
		case likedPosts
	}
}

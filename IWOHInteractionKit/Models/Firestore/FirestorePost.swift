import Foundation
import FirebaseFirestoreSwift
import Firebase

public struct FirestorePost: Storeable {
	public let message: String
	public let geohash: String?
	public let coordinates: GeoPoint
	public let altitude: Double
	public let heading: Double
	public let date: Date
	public let languageCode: String
	public let likes: UInt
	public let id: String
    public let translated: Translated?
	public let creatorID: String

	public init(post: Post) {
		self.message = post.message
		self.coordinates = GeoPoint(latitude: post.location.latitude, longitude: post.location.longitude)
		self.altitude = post.location.altitude
		self.heading = post.heading?.trueHeading ?? 0
		self.date = post.date
		self.languageCode = post.languageCode
		self.likes = post.likes
		self.id = post.id.uuidString
		self.translated = nil
		self.geohash = nil
		self.creatorID = post.creatorID
	}
}

extension FirestorePost {
	typealias Fields = CollectionFields

	public static let collectionPath = "posts"

	public enum CollectionFields: String {
		case date
		case likes
		case geohash
	}
}

extension Location {
	public init(firestorePost: FirestorePost) {
		self.longitude = firestorePost.coordinates.longitude
		self.latitude = firestorePost.coordinates.longitude
		self.altitude = firestorePost.altitude
	}
}

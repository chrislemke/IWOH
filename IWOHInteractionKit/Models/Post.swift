import Foundation

public struct Post: Equatable {

	public let message: String
	public let location: Location
	public let heading: LocationHeading?
	public let date: Date
	public let languageCode: String
	public let likes: UInt
	public let id: UUID
	public let geohash: String?
	public let creatorID: String
    public let translated: Translated?

	public init(message: String,
		 location: Location,
		 heading: LocationHeading?,
		 date: Date,
		 languageCode: String,
		 likes: UInt,
		 creatorID: String) {
		self.message = message
		self.location = location
		self.heading = heading
		self.date = date
		self.languageCode = languageCode
		self.id = UUID()
		self.likes = likes
        self.translated = nil
		self.geohash = nil
		self.creatorID = creatorID
	}

	public init(firestorePost: FirestorePost) {
		guard let identifier = UUID(uuidString: firestorePost.id) else {
			fatalError("Could not parse id of type String to UUID!")
		}

		self.message = firestorePost.message
		self.location = Location(latitude: firestorePost.coordinates.latitude,
                                longitude: firestorePost.coordinates.longitude,
                                altitude: firestorePost.altitude)
		self.heading = LocationHeading(trueHeading: firestorePost.heading)
		self.date = firestorePost.date
		self.languageCode = firestorePost.languageCode
		self.id = identifier
		self.likes = firestorePost.likes
        self.translated = firestorePost.translated
		self.geohash = firestorePost.geohash
		self.creatorID = firestorePost.creatorID
	}

	public static func == (lhs: Post, rhs: Post) -> Bool {
		lhs.id == rhs.id
	}
}

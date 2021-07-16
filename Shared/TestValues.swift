import Foundation
import IWOHInteractionKit
@testable import IWOH

struct TestValues {

	static let latitude = 52.512904272743434

	static let longitude = 13.471657546130706

	static let geohash = "u33ddx9vb"

	static let altitude = 38.89

	static let distance = 7.0

	static let location = Location(latitude: latitude, longitude: longitude, altitude: altitude)

	static let heading = 90.0

	static let locationHeading = LocationHeading(trueHeading: heading)

	static let languageCode = "en"

	static let likesCount: UInt = 7

	static let date = Date(timeIntervalSince1970: 0)

	static let creatorID = "creatorID"

	static let post = Post(message: message,
						location: location,
						heading: locationHeading,
						date: date,
						languageCode: languageCode,
						likes: likesCount,
						creatorID: creatorID)

	static let message = "This is a test message."

	static let shortMessage = "CML"

	// swiftlint:disable:next line_length
	static let tooLongMessage196 = """
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolo
"""

	static let postMessage = PostMessage(message: message, location: location)

	static let postAnnotationActive = PostAnnotation(post: post, active: true)

	static let firestorePost = FirestorePost(post: post)
}

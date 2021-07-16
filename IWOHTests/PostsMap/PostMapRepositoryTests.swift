import XCTest
import CombineTestExtensions
import Combine
import IWOHInteractionKit
@testable import IWOH

final class PostsMapRepositoryTests: XCTestCase {

	private var firestoreManagerMock: FirestoreManagerMock!
	private var systemUnderTest: PostsMapRepository!
	private var cancellableSet = Set<AnyCancellable>()
	private var scheduler: TestScheduler!


	override func setUp() {
		super.setUp()
		scheduler = .init()

		firestoreManagerMock = FirestoreManagerMock(scheduler: scheduler)

		let locationManager = Swinjector.shared.resolve(LocationManager.self)

		systemUnderTest = PostsMapRepository(locationManager: locationManager, firestoreManager: firestoreManagerMock)
	}

	override func tearDown() {
		systemUnderTest = nil
		scheduler = nil
		super.tearDown()
	}

	func testCorrectMappingFromFirestorePostToPost() {
		let record = systemUnderTest.posts
		.record(scheduler: scheduler, numberOfRecords: 1)
		.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(100, .value([TestValues.post]))])
	}
}

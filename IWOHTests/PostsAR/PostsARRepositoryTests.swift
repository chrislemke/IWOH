import XCTest
import CombineTestExtensions
import Combine
@testable import IWOH

final class PostsARRepositoryTests: XCTestCase {

	private var systemUnderTest: PostsARRepository!
	private var cancellableSet = Set<AnyCancellable>()
	private var scheduler: TestScheduler!

	override func setUp() {
		super.setUp()
		scheduler = .init()
		systemUnderTest = PostsARRepository(firestoreManager: FirestoreManagerMock(scheduler: scheduler))
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

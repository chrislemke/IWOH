import XCTest
import CombineTestExtensions
import Combine
@testable import IWOH

final class PostDetailsRepositoryTests: XCTestCase {

	private var scheduler: TestScheduler!
	private var userManagerMock: UserManagerMock!
	private var systemUnderTest: PostDetailsRepository!

	override func setUp() {
		super.setUp()
		scheduler = .init()
		userManagerMock = UserManagerMock()
		systemUnderTest = PostDetailsRepository(locationManager: LocationManagerMock(), userManager: userManagerMock, firestoreManager: FirestoreManagerMock(scheduler: scheduler))
	}

	override func tearDown() {
		scheduler = nil
		systemUnderTest = nil
		super.tearDown()
	}

	func testCanLikePostCombinesReturnTrueIfBothReturnFalse() {
		userManagerMock.isLikedByUserHandler = { _ in
			TestPublisher<Bool, Never>(self.scheduler, [(100, .value(false))]).eraseToAnyPublisher()
		}
		userManagerMock.isCreatedByUserHandler = { _ in
			TestPublisher<Bool, Never>(self.scheduler, [(100, .value(false))]).eraseToAnyPublisher()
		}
		systemUnderTest = PostDetailsRepository(locationManager: LocationManagerMock(), userManager: userManagerMock, firestoreManager: FirestoreManagerMock(scheduler: scheduler))

		let record = systemUnderTest.canLikePost(TestValues.post)
		.record(scheduler: scheduler, numberOfRecords: 1)
		.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(100, .value(true))])
	}

	func testCanLikePostCombinesReturnFalseIfOneReturnsFalse() {
		userManagerMock.isLikedByUserHandler = { _ in
			TestPublisher<Bool, Never>(self.scheduler, [(100, .value(true))]).eraseToAnyPublisher()
		}
		userManagerMock.isCreatedByUserHandler = { _ in
			TestPublisher<Bool, Never>(self.scheduler, [(100, .value(false))]).eraseToAnyPublisher()
		}
		systemUnderTest = PostDetailsRepository(locationManager: LocationManagerMock(), userManager: userManagerMock, firestoreManager: FirestoreManagerMock(scheduler: scheduler))

		let record = systemUnderTest.canLikePost(TestValues.post)
			.record(scheduler: scheduler, numberOfRecords: 1)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(100, .value(false))])
	}

	func testLikesReturnCorrectNumber() {
		let record = systemUnderTest.likes(for: TestValues.post)
			.record(scheduler: scheduler, numberOfRecords: 1)
			.waitAndCollectTimedRecords()

			XCTAssertEqual(record, [(100, .value(7))])
	}
}

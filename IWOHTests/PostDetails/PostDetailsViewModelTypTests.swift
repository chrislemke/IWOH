import XCTest
import CombineTestExtensions
import Combine
@testable import IWOH

final class PostDetailsViewModelTypTests: XCTestCase {

	private var scheduler: TestScheduler!
	private var systemUnderTest: CalloutViewModel! // This viewModel applies the PostDetailsViewModelTyp protocol.
	private var repositoryMock: PostDetailsRepositoryMock!

	override func setUp() {
		super.setUp()
		scheduler = .init()
		repositoryMock = PostDetailsRepositoryMock(scheduler: scheduler)
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)
	}

	override func tearDown() {
		scheduler = nil
		systemUnderTest = nil
		repositoryMock = nil
		super.tearDown()
	}

	func testLikePostCallsRepository() {
		systemUnderTest.likePost()
		XCTAssertEqual(repositoryMock.likePostCallCount, 1)
	}

	func testAssignToLikes() {
		let record = systemUnderTest.$likes
		.record(scheduler: scheduler, numberOfRecords: 1)
		.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(TestValues.likesCount))])
	}

	func testAssignToLikedByUser() {

		repositoryMock.canLikePostHandler = { _ in
			TestPublisher<Bool, Never>(self.scheduler, [(100, .value(false))]).eraseToAnyPublisher()
		}

		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let record = systemUnderTest.$likingDisabled
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(true)), (100, .value(true))])
	}

	func testCurrentLocationDistanceStringReturnsNearby() {
		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "nearby")
	}

	func testCurrentLocationDistanceStringReturnsMetersAway() {

		repositoryMock.distanceHandler = { _ in
			11
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "11 m away")
	}

	func testCurrentLocationDistanceStringReturnsKmAway() {

		repositoryMock.distanceHandler = { _ in
			1001
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)
		
		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "1.0 km away")
	}

	func testCurrentLocationDistanceStringReturnsFarAway() {

		repositoryMock.distanceHandler = { _ in
			100001
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "far away")
	}

	func testCurrentLocationDistanceStringReturnsVeryFarAway() {

		repositoryMock.distanceHandler = { _ in
			400001
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "very far away")
	}

	func testCurrentLocationDistanceStringReturnsExtremelyFarAway() {

		repositoryMock.distanceHandler = { _ in
			1000001
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "extremely far away")
	}

	func testCurrentLocationDistanceStringReturnsStillOnThePlanet() {

		repositoryMock.distanceHandler = { _ in
			4000001
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "still on the planet")
	}

	func testCurrentLocationDistanceStringReturnsSomewhere() {

		repositoryMock.distanceHandler = { _ in
			-1
		}
		systemUnderTest = CalloutViewModel(post: TestValues.post, repository: repositoryMock)

		let distanceString = systemUnderTest.currentLocationDistanceString(from: TestValues.location).string

		XCTAssertEqual(distanceString, "somewhere")
	}
}

import XCTest
import CombineTestExtensions
import Combine
import IWOHInteractionKit
@testable import IWOH

final class PostsMapViewModelTests: XCTestCase {

	private var repositoryMock: PostsMapRepositoryTyp!
	private var systemUnderTest: PostsMapViewModel!
	private var cancellableSet = Set<AnyCancellable>()

	override func setUp() {
		super.setUp()

		repositoryMock = PostsMapRepositoryMock(
			locationAuthenticationStatus: Just<LocationAuthenticationStatus>(.authorizedWhenInUse).eraseToAnyPublisher(),
			currentLocation: Just<LocationManager.State>(.location(TestValues.location)).eraseToAnyPublisher(),
			locationHeading: Just<LocationHeading?>(TestValues.locationHeading).eraseToAnyPublisher(),
			posts: Just<[Post]>([TestValues.post]).eraseToAnyPublisher(), location: LocationManager.State.location(TestValues.location))

		systemUnderTest = PostsMapViewModel(repository: repositoryMock)
	}

	override func tearDown() {
		repositoryMock = nil
		systemUnderTest = nil
		super.tearDown()
	}

	func testAssignToPostAnnotation() {
		let expectation = XCTestExpectation(description: "assign post annotations")

		 systemUnderTest.$annotations
			// Drop empty annotations array from init
			.dropFirst()
			.sink { annotations in
				XCTAssertEqual(annotations.first?.post.id, PostAnnotation(post: TestValues.post, active: true).post.id)
		}
		.store(in: &cancellableSet)

		delayInMilliseconds(500) {
			expectation.fulfill()
		}
		wait(for: [expectation], timeout: 1)
	}
}

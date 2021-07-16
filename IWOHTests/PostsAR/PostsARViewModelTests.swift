import XCTest
import CombineTestExtensions
import Combine
import IWOHInteractionKit
@testable import IWOH

final class PostsARViewModelTests: XCTestCase {

	private var repositoryMock: PostARRepositoryTyp!
	private var scheduler: TestScheduler!
	private var systemUnderTest: PostsARViewModel!
	private var cancellableSet = Set<AnyCancellable>()


    override func setUp(){
		super.setUp()

		scheduler = TestScheduler()

		repositoryMock = PostARRepositoryTypMock(posts: Just<[Post]>([TestValues.post]).eraseToAnyPublisher())

		systemUnderTest = PostsARViewModel(repository: repositoryMock)

    }

	override func tearDown() {
		repositoryMock = nil
		systemUnderTest = nil
		super.tearDown()
	}

	func testAssignToAnnotationViewModels() {
		let expectation = XCTestExpectation(description: "assign to viewModels")

		systemUnderTest.$annotationViewModels
			// Drop empty viewModel array from init
			.dropFirst()
			.sink { viewModels in
				let expected = Swinjector.shared.resolve(PostARAnnotationViewModel.self, argument: TestValues.post).post.id
				XCTAssertEqual(viewModels.first?.post.id, expected)
		}
		.store(in: &cancellableSet)

		delayInMilliseconds(500) {
			expectation.fulfill()
		}
		wait(for: [expectation], timeout: 1)
	}
}

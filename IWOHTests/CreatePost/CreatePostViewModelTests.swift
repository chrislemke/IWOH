import XCTest
import CombineTestExtensions
import Combine
import IWOHInteractionKit
@testable import IWOH

final class CreatePostViewModelTests: XCTestCase {

	private var scheduler: TestScheduler!
	private var repositoryMock: CreatePostRepositoryMock!
	private var systemUnderTest: CreatePostViewModel!

	override func setUp() {
		super.setUp()
		scheduler = .init()

		repositoryMock =
			CreatePostRepositoryMock(
									 locationAuthenticationStatus: TestPublisher(scheduler, [(100, .value(.authorizedWhenInUse))]).eraseToAnyPublisher(),
									 location: TestPublisher(scheduler, [(100, .value(.location(TestValues.location)))]).eraseToAnyPublisher(),
									 locationHeading: TestPublisher(scheduler, [(100, .value(TestValues.locationHeading))]).eraseToAnyPublisher())

		repositoryMock.submitHandler = { _ in
			return Just<SubmissionState>(SubmissionState.success("success")).eraseToAnyPublisher()
		}

		systemUnderTest = CreatePostViewModel(repository: repositoryMock)
	}

	override func tearDown() {
		scheduler = nil
		repositoryMock = nil
		systemUnderTest = nil
		super.tearDown()
	}

	func testWarningMessageSetToNoWaring() {
		systemUnderTest.postMessage = TestValues.message
		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.noWarning))])
	}

	func testWarningMessageSetToNoMessage() {
		systemUnderTest.postMessage = ""
		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.noMessage))])
	}

	func testWarningMessageSetToTooLong() {
		systemUnderTest.postMessage = TestValues.tooLongMessage196
		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.messageToLong))])
	}

	func testWarningMessageSetToNoLocation() {

		repositoryMock.location = TestPublisher(scheduler, [(100, .value(.error))]).eraseToAnyPublisher()
		systemUnderTest = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest.postMessage = TestValues.message

		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.noLocation))])
	}

	func testWarningMessageSetToNoLocationCauseByNotAuthorized() {
		repositoryMock.locationAuthenticationStatus = TestPublisher(scheduler, [(100, .value(.notDetermined))]).eraseToAnyPublisher()
		systemUnderTest = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest.postMessage = TestValues.message

		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.noLocation))])
	}

	func testWarningMessageSetToTooLongNoLocation() {
		repositoryMock.location = TestPublisher(scheduler, [(100, .value(.error))]).eraseToAnyPublisher()
		systemUnderTest = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest.postMessage = TestValues.tooLongMessage196

		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.messageToLongNoLocation))])
	}

	func testWarningMessageSetToNoMessageNoLocation() {
		repositoryMock.location = TestPublisher(scheduler, [(100, .value(.error))]).eraseToAnyPublisher()
		systemUnderTest = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest.postMessage = nil

		let record = systemUnderTest.$warningMessageState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(WarningMessageState.unspecified)),
								(100, .value(WarningMessageState.noMessageNoLocation))])
	}

	func testAssigningLocation() {

		let record = systemUnderTest.$location
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(LocationManager.State.unspecified)),
								(100, .value(LocationManager.State.location(TestValues.location)))])
	}

	func testSubmittingEmptyMessage() {

		systemUnderTest.postMessage = nil

		delayInMilliseconds(500) {
			self.systemUnderTest.sendPost()
		}

		let record = systemUnderTest.$submissionState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords(timeout: 1)

		XCTAssertEqual(record, [(0, .value(SubmissionState.unspecified)),
								(100, .value(SubmissionState.error(nil)))])
	}

	func testSubmittingEmptyLocation() {

		repositoryMock.location = TestPublisher(scheduler, [(100, .value(.error))]).eraseToAnyPublisher()
		systemUnderTest = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest.postMessage = TestValues.message

		delayInMilliseconds(500) {
			self.systemUnderTest.sendPost()
		}

		let record = systemUnderTest.$submissionState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords(timeout: 1)

		XCTAssertEqual(record, [(0, .value(SubmissionState.unspecified)),
								(100, .value(SubmissionState.error(nil)))])
	}

	func testSuccessfulSubmitting() {

		systemUnderTest.postMessage = TestValues.message

		delayInMilliseconds(500) {
			self.systemUnderTest.sendPost()
		}

		let record = systemUnderTest.$submissionState
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords(timeout: 1)

		XCTAssertEqual(record, [(0, .value(SubmissionState.unspecified)),
								(100, .value(SubmissionState.success("success")))])

		XCTAssertEqual(repositoryMock.submitCallCount, 1)
	}
}

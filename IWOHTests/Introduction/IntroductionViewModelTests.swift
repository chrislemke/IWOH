import XCTest
import CombineTestExtensions
import Combine
import IWOHInteractionKit
@testable import IWOH

final class IntroductionViewModelTests: XCTestCase {

	private var scheduler: TestScheduler!
	private var repositoryMock: IntroductionRepositoryTyp!
	private var systemUnderTest: IntroductionViewModel!

	override func setUp() {
		super.setUp()
		scheduler = .init()
	}

	override func tearDown() {
		scheduler = nil
		repositoryMock = nil
		systemUnderTest = nil
		super.tearDown()
	}

	func testToggleTappedIsSetWithLocationAuthenticationWhenInUse() {

		repositoryMock = IntroductionRepositoryMock(locationAuthenticationStatus: TestPublisher(scheduler, [(100, .value(LocationAuthenticationStatus.authorizedWhenInUse))]).eraseToAnyPublisher())

		systemUnderTest = IntroductionViewModel(repository: repositoryMock)

		let record = systemUnderTest.$isLocationServiceToggleTapped
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(false)),
								(100, .value(true))])
	}

	func testToggleTappedIsSetWithLocationAuthenticationDenied() {

		repositoryMock = IntroductionRepositoryMock(locationAuthenticationStatus: TestPublisher(scheduler, [(100, .value(LocationAuthenticationStatus.denied))]).eraseToAnyPublisher())

		systemUnderTest = IntroductionViewModel(repository: repositoryMock)

		let record = systemUnderTest.$isLocationServiceToggleTapped
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(false)),
								(100, .value(true))])
	}

	func testToggleTappedIsSetWithLocationAuthenticationNotDetermined() {

		repositoryMock = IntroductionRepositoryMock(locationAuthenticationStatus: TestPublisher(scheduler, [(100, .value(LocationAuthenticationStatus.notDetermined))]).eraseToAnyPublisher())

		systemUnderTest = IntroductionViewModel(repository: repositoryMock)

		let record = systemUnderTest.$isLocationServiceToggleTapped
			.record(scheduler: scheduler, numberOfRecords: 2)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(0, .value(false)),
								(100, .value(false))])
	}
}

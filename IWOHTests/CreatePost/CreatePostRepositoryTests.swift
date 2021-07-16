import XCTest
import CombineTestExtensions
import Combine
import IWOHInteractionKit
@testable import IWOH

final class CreatePostRespsitoryTests: XCTestCase {

	private var scheduler: TestScheduler!
	private var systemUnderTest: CreatePostRepositoryTyp!
	private var mlManagerStub: MLManagerStub!
	private var firestoreManagerMock: FirestoreManagerMock!
	private var locationManagerMock: LocationManagerMock!

	override func setUp() {
		super.setUp()
		scheduler = .init()

		mlManagerStub = MLManagerStub(scheduler: scheduler)
		firestoreManagerMock = FirestoreManagerMock(scheduler: scheduler)

		locationManagerMock = LocationManagerMock(authenticationStatus: TestPublisher(scheduler, [(100, .value(.authorizedWhenInUse))]).eraseToAnyPublisher(),
												  locationHeading: TestPublisher(scheduler, [(100, .value(TestValues.locationHeading))]).eraseToAnyPublisher(),
												  currentLocation: TestPublisher(scheduler, [(100, .value(.location(TestValues.location)))]).eraseToAnyPublisher(), location: LocationManager.State.location(TestValues.location))

		systemUnderTest = CreatePostRepository(locationManager: locationManagerMock,
											   firestoreManager: firestoreManagerMock,
											   mlManager: mlManagerStub,
											   userManager: Swinjector.shared.resolve(UserManager.self),
											   authenticationManager: Swinjector.shared.resolve(AuthenticationManager.self))
	}

	override func tearDown() {
		scheduler = nil
		systemUnderTest = nil
		mlManagerStub = nil
		firestoreManagerMock = nil
		locationManagerMock = nil
		super.tearDown()
	}

	func testSuccessfulSubmitMessage() {

		let record = systemUnderTest.submit(postMessage: TestValues.postMessage)
			.record(scheduler: scheduler, numberOfRecords: 1)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(100, .value(SubmissionState.success("id")))])
	}

	func testSuccessfulSubmitMessageOmittingFurtherEvents() {

		locationManagerMock.locationHeading = TestPublisher(scheduler, [(100, .value(TestValues.locationHeading)), (200, .value(TestValues.locationHeading)), (300, .value(TestValues.locationHeading))]).eraseToAnyPublisher()
		
		systemUnderTest = CreatePostRepository(locationManager: locationManagerMock,
											   firestoreManager: firestoreManagerMock,
											   mlManager: mlManagerStub,
											   userManager: Swinjector.shared.resolve(UserManager.self),
											   authenticationManager: Swinjector.shared.resolve(AuthenticationManager.self))

		let record = systemUnderTest.submit(postMessage: TestValues.postMessage)
			.record(scheduler: scheduler, numberOfRecords: 1)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(100, .value(SubmissionState.success("id")))])
	}

	func testSubmitMessageWithFailingAddingToStore() {

		let mock = FirestoreManagerMock(scheduler: scheduler)

		mock.addHandler = { _ in
			TestPublisher<SubmissionState, Never>(self.scheduler, [(100, .value(SubmissionState.error(nil)))]).eraseToAnyPublisher()
		}

		systemUnderTest = CreatePostRepository(locationManager: locationManagerMock,
											   firestoreManager: mock,
											   mlManager: mlManagerStub,
											   userManager: Swinjector.shared.resolve(UserManager.self),
											   authenticationManager: Swinjector.shared.resolve(AuthenticationManager.self))

		let record = systemUnderTest.submit(postMessage: TestValues.postMessage)
			.record(scheduler: scheduler, numberOfRecords: 1)
			.waitAndCollectTimedRecords()

		XCTAssertEqual(record, [(100, .value(SubmissionState.error(nil)))])
	}
}

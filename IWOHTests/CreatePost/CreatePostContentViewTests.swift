import XCTest
import ViewInspector
import Combine
@testable import IWOH
import IWOHInteractionKit

extension WarningLabel: Inspectable {}
extension CreatePostContentView: Inspectable {}

final class CreatePostContentViewTests: XCTestCase {

	private var systemUnderTest: CreatePostContentView!
	private var repositoryMock: CreatePostRepositoryMock!

	override func setUpWithError() throws {
		try super.setUpWithError()
		repositoryMock = CreatePostRepositoryMock(
												  locationAuthenticationStatus:
													Just<LocationAuthenticationStatus>(.authorizedWhenInUse).eraseToAnyPublisher(),
												  location: Just<LocationManager.State>(.location(TestValues.location)).eraseToAnyPublisher(),
												  locationHeading: Just<LocationHeading?>(TestValues.locationHeading).eraseToAnyPublisher())
		let viewModel = CreatePostViewModel(repository: self.repositoryMock)

		systemUnderTest = CreatePostContentView(viewModel: viewModel)
		ViewHosting.host(view: systemUnderTest)
	}

	override func tearDownWithError() throws {
		systemUnderTest = nil
		repositoryMock = nil
		try super.tearDownWithError()
	}

	func testWarningMessageIsSetToNoMessage() {
		let expectation = systemUnderTest.inspection.inspect { view in
			let text = try view.navigationView().zStack(0).vStack(1).view(WarningLabel.self, 0).text().string()

			XCTAssertEqual(text, "create.post.no.message.text")
		}
		wait(for: [expectation], timeout: 1)
	}

	func testWarningMessageIsSetToNoWarning() {
		systemUnderTest.viewModel.postMessage = TestValues.message
		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let text = try view.navigationView().zStack(0).vStack(1).view(WarningLabel.self, 0).text().string()

			XCTAssertEqual(text, "create.post.no.warning.text")
		}
		wait(for: [expectation], timeout: 2)
	}

	func testWarningMessageIsSetToTooLongMessage() {
		systemUnderTest.viewModel.postMessage = TestValues.tooLongMessage196
		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let text = try view.navigationView().zStack(0).vStack(1).view(WarningLabel.self, 0).text().string()

			XCTAssertEqual(text, "create.post.message.too.long.text")
		}
		wait(for: [expectation], timeout: 2)
	}

	func testWarningMessageIsSetToNoLocation() {

		repositoryMock.location = Just<LocationManager.State>(.error).eraseToAnyPublisher()
		let viewModel = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest = CreatePostContentView(viewModel: viewModel)
		ViewHosting.host(view: systemUnderTest)

		systemUnderTest.viewModel.postMessage = TestValues.message
		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let text = try view.navigationView().zStack(0).vStack(1).view(WarningLabel.self, 0).text().string()

			XCTAssertEqual(text, "create.post.no.location.text")
		}
		wait(for: [expectation], timeout: 2)
	}

	func testWarningMessageIsSetToNoMessageNoLocation() {
		repositoryMock.location = Just<LocationManager.State>(.error).eraseToAnyPublisher()
		let viewModel = CreatePostViewModel(repository: self.repositoryMock)
		systemUnderTest = CreatePostContentView(viewModel: viewModel)
		ViewHosting.host(view: systemUnderTest)

		systemUnderTest.viewModel.postMessage = ""
		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let text = try view.navigationView().zStack(0).vStack(1).view(WarningLabel.self, 0).text().string()

			XCTAssertEqual(text, "create.post.no.message.no.location.text")
		}
		wait(for: [expectation], timeout: 2)
	}
}

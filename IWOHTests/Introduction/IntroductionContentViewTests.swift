import XCTest
import ViewInspector
import Combine
import IWOHInteractionKit
@testable import IWOH

extension IntroductionContentView: Inspectable {}
extension IntroductionButtons: Inspectable {}

final class IntroductionContentViewTests: XCTestCase {

	private var systemUnderTest: IntroductionContentView!
	private var repositoryMock: IntroductionRepositoryMock!

	override func setUpWithError() throws {
		try super.setUpWithError()

		self.repositoryMock = IntroductionRepositoryMock(locationAuthenticationStatus: Just<LocationAuthenticationStatus>(.authorizedWhenInUse).eraseToAnyPublisher())

		let viewModel = IntroductionViewModel(repository: self.repositoryMock)

		systemUnderTest = IntroductionContentView(viewModel: viewModel)
		ViewHosting.host(view: systemUnderTest)
	}

	override func tearDownWithError() throws {
		systemUnderTest = nil
		try super.tearDownWithError()
	}

	func testLocationFillImageNameIsSetForButton() {
		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let imageName = try view.geometryReader().vStack().vStack(1).view(IntroductionButtons.self, 3).actualView().locationToggleImageName()

			XCTAssertEqual(imageName, "location.fill")
		}
		wait(for: [expectation], timeout: 2)
	}

	func testLocationImageNameIsSetForButton() {
		repositoryMock.locationAuthenticationStatus = Just<LocationAuthenticationStatus>(.notDetermined).eraseToAnyPublisher()
		let viewModel = IntroductionViewModel(repository: self.repositoryMock)
		systemUnderTest = IntroductionContentView(viewModel: viewModel)
		ViewHosting.host(view: systemUnderTest)

		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let imageName = try view.geometryReader().vStack().vStack(1).view(IntroductionButtons.self, 3).actualView().locationToggleImageName()

			XCTAssertEqual(imageName, "location")
		}
		wait(for: [expectation], timeout: 2)
	}

	func testLocationSlashImageNameIsSetForButton() {
		repositoryMock.locationAuthenticationStatus = Just<LocationAuthenticationStatus>(.denied).eraseToAnyPublisher()
		let viewModel = IntroductionViewModel(repository: self.repositoryMock)
		systemUnderTest = IntroductionContentView(viewModel: viewModel)
		ViewHosting.host(view: systemUnderTest)

		let expectation = systemUnderTest.inspection.inspect(after: 1) { view in
			let imageName = try view.geometryReader().vStack().vStack(1).view(IntroductionButtons.self, 3).actualView().locationToggleImageName()

			XCTAssertEqual(imageName, "location.slash")
		}
		wait(for: [expectation], timeout: 2)
	}
}

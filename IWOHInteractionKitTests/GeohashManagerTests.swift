import XCTest
@testable import IWOHInteractionKit

final class IWOHInteractionKitTests: XCTestCase {

	func testCorrectGeohashReturnedFromLocation() {
		let result = GeohashManager.geohash(for: TestValues.location)

		XCTAssertEqual(result, TestValues.geohash)
	}

	func testUpperGeohashIsCorrentWithOffset2() {
		let result = GeohashManager.upperGeohash(from: TestValues.location, offset: -2)
		XCTAssertEqual(result, "u33ddx9˜")
	}

	func testUpperGeohashIsCorrentWithOffset4() {
		let result = GeohashManager.upperGeohash(from: TestValues.location, offset: -4)
		XCTAssertEqual(result, "u33dd˜")
	}

	func testUpperGeohashIsCorrentWithInvalidOffset() {
		let result = GeohashManager.upperGeohash(from: TestValues.location, offset: 0)
		XCTAssertEqual(result, "")
	}
}

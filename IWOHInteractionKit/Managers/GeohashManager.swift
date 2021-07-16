import Foundation

public struct GeohashManager {

	public static func geohash(for location: Location) -> String {
		Geohash.encode(latitude: location.latitude, longitude: location.longitude, length: 9)
	}

	public static func upperGeohash(from location: Location, offset: Int) -> String {

		if offset < -8 || offset > -1 {
			logError("Unvalid offset! Must be between '-8' and '-1'.")
			return ""
		}

		let locationGeohash = GeohashManager.geohash(for: location)
		// swiftlint:disable:next line_length
		let range = locationGeohash.index(locationGeohash.endIndex, offsetBy: offset)...locationGeohash.index(before: locationGeohash.endIndex)
		return locationGeohash.replacingCharacters(in: range, with: "˜")
	}

	public static func closestHash(_ locationGeohash: String, locations: [String]) -> String? {
		if locationGeohash.count != 9, locations.first(where: {  $0.count != 9 }) == nil {
			return nil
		}

		return locations.max { first, second in
			// swiftlint:disable:next line_length
			characterDifferenceAtPostion(from: locationGeohash, and: first) < characterDifferenceAtPostion(from: locationGeohash, and: second)
		}
	}

	private static func characterDifferenceAtPostion(from first: String,
													and second: String) -> UInt {
		var count: UInt = 0
		for index in 0..<first.count {
			let char = first[safe: index]
			if char == second[safe: index] {
				count += 1
			} else {
				break
			}
		}
		return count
	}
}

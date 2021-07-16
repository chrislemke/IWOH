import Foundation

public struct Geohash {
	// swiftlint:disable:next line_length
	public static func decode(hash: String) -> (latitude: (min: Double, max: Double), longitude: (min: Double, max: Double))? {

		let bits = hash.map { bitmap[$0] ?? "?" }.joined(separator: "")
		guard bits.count % 5 == 0 else { return nil }

		let (lat, lon) = bits.enumerated().reduce(into: ([Character](), [Character]())) {
			if $1.0 % 2 == 0 {
				$0.1.append($1.1)
			} else {
				$0.0.append($1.1)
			}
		}

		func combiner(array a: (min: Double, max: Double), value: Character) -> (Double, Double) {
			let mean = (a.min + a.max) / 2
			return value == "1" ? (mean, a.max) : (a.min, mean)
		}

		let latRange = lat.reduce((-90.0, 90.0), combiner)

		let lonRange = lon.reduce((-180.0, 180.0), combiner)

		return (latRange, lonRange)
	}

	public static func encode(latitude: Double, longitude: Double, length: Int) -> String {

		// swiftlint:disable:next large_tuple
		func combiner(array a: (min: Double, max: Double, array: [String]), value: Double) -> (Double, Double, [String]) {
			let mean = (a.min + a.max) / 2
			if value < mean {
				return (a.min, mean, a.array + "0")
			} else {
				return (mean, a.max, a.array + "1")
			}
		}

		let lat = Array(repeating: latitude, count: length*5).reduce((-90.0, 90.0, [String]()), combiner)

		let lon = Array(repeating: longitude, count: length*5).reduce((-180.0, 180.0, [String]()), combiner)

		let latlon = lon.2.enumerated().flatMap { [$1, lat.2[$0]] }

		let bits = latlon.enumerated().reduce([String]()) { $1.0 % 5 > 0 ? $0 << $1.1 : $0 + $1.1 }

		let arr = bits.compactMap { charmap[$0] }

		return String(arr.prefix(length))
	}

	// MARK: - Private
	private static let bitmap = "0123456789bcdefghjkmnpqrstuvwxyz".enumerated()
		.map {
			($1, String(integer: $0, radix: 2, padding: 5))
	}
	.reduce(into: [Character: String]()) {
		$0[$1.0] = $1.1
	}

	private static let charmap = bitmap
		.reduce(into: [String: Character]()) {
			$0[$1.1] = $1.0
	}
}

public extension Geohash {
	enum Precision: Int {
		case twentyFiveHundredKilometers = 1    // ±2500 km
		case sixHundredThirtyKilometers         // ±630 km
		case seventyEightKilometers             // ±78 km
		case twentyKilometers                   // ±20 km
		case twentyFourHundredMeters            // ±2.4 km
		case sixHundredTenMeters                // ±0.61 km
		case seventySixMeters                   // ±0.076 km
		case nineteenMeters                     // ±0.019 km
		case twoHundredFourtyCentimeters        // ±0.0024 km
		case sixtyCentimeters                   // ±0.00060 km
		case seventyFourMillimeters             // ±0.000074 km
	}

	static func encode(latitude: Double, longitude: Double, precision: Precision) -> String {
		return encode(latitude: latitude, longitude: longitude, length: precision.rawValue)
	}
}

private func + (left: [String], right: String) -> [String] {
	var arr = left
	arr.append(right)
	return arr
}

private func << (left: [String], right: String) -> [String] {
	var arr = left
	var s = arr.popLast()!
	s += right
	arr.append(s)
	return arr
}

private extension String {
	init(integer n: Int, radix: Int, padding: Int) {
		let s = String(n, radix: radix)
		let pad = (padding - s.count % padding) % padding
		self = Array(repeating: "0", count: pad).joined(separator: "") + s
	}
}

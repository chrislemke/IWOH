import Foundation

public struct Location: Codable, Hashable {
	public let latitude: Double
	public let longitude: Double
	public let altitude: Double

	public init(latitude: Double, longitude: Double, altitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
		self.altitude = altitude
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
		hasher.combine(altitude)
	}
}

public struct LocationHeading: Codable {
	let trueHeading: Double

	public init(trueHeading: Double) {
		self.trueHeading = trueHeading
	}
 }

public struct CoordinateSpan {
	public let latitudeDelta: Double
	public let longitudeDelta: Double

	public init(latitudeDelta: Double, longitudeDelta: Double) {
		self.latitudeDelta = latitudeDelta
		self.longitudeDelta = longitudeDelta
	}
}

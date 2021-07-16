import DeviceKit
import Foundation

struct DeviceManager {

	// MARK: - Private

	private static var smallDevices: [Device] {
		return [
			Device.iPhoneSE,
			Device.simulator(.iPhoneSE)
		]
	}

	private static var mediumDevices: [Device] {
		return [
			Device.iPhone6,
			Device.iPhone7,
			Device.iPhone8,
			Device.simulator(.iPhone6),
			Device.simulator(.iPhone7),
			Device.simulator(.iPhone8)
		]
	}

	// MARK: - Public

	static func isSmallDevice() -> Bool {
		return Device.current.isOneOf(smallDevices)
	}

	static func isMediumDevice() -> Bool {
		return Device.current.isOneOf(mediumDevices)
	}

	static func isSmallOrMediumDevice() -> Bool {
		return isSmallDevice() || isMediumDevice()
	}

	static func isSimulator() -> Bool {
		return Device.current.isSimulator
	}
}

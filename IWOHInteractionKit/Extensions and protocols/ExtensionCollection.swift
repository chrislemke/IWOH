import Foundation
import Combine

extension BidirectionalCollection {
	subscript(safe offset: Int) -> Element? {
		// swiftlint:disable:next line_length
		guard !isEmpty, let index = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
		return self[index]
	}
}

extension LocationManager.State: Equatable {
	public static func == (lhs: LocationManager.State, rhs: LocationManager.State) -> Bool {
		switch (lhs, rhs) {
			case (.unspecified, .unspecified): return true
			case let (.location(l), .location(r)): return l == r
			case (.error, .error): return true
			default: return false
		}
	}
}

extension SubmissionState: Equatable {
	public static func == (lhs: SubmissionState, rhs: SubmissionState) -> Bool {
		switch (lhs, rhs) {
			case (.unspecified, .unspecified): return true
			case let (.success(l), .success(r)): return l == r
			case let (.error(l), .error(r)):
				return l?.localizedDescription == r?.localizedDescription
			default: return false
		}
	}
}

extension Date {
	public func fullDateWithYear() -> String {
		let formatter = DateFormatter.format(with: .autoupdatingCurrent)
		return formatter.string(from: self, format: "MMMM dd, yyyy")
	}

	public func dateWithYear() -> String {
		let formatter = DateFormatter.format(with: .autoupdatingCurrent)
		return formatter.string(from: self, format: "MMM dd, yyyy")
	}

	public func dateWithoutYear() -> String {
		let formatter = DateFormatter.format(with: .autoupdatingCurrent)
		return formatter.string(from: self, format: "MMM dd")
	}
}

extension DateFormatter {
	static var defaultFormatter: DateFormatter {
		let formatter = DateFormatter()
		return formatter
	}

	fileprivate static func format(with timeZone: TimeZone) -> DateFormatter {
		let formatter = DateFormatter.defaultFormatter
		formatter.timeZone = timeZone
		return formatter
	}

	fileprivate func string(from date: Date, format: String) -> String {
		self.dateFormat = format
		return self.string(from: date)
	}
}

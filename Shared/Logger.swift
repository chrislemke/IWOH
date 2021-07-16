/// Shared membership

import Foundation

private let kNoFileMessage = "Could not resolve file name!"

private enum LegLevel: Int {
	case none
	case error
	case warning
	case info
	case debug
	case verbose
}

private var logLevelL: LegLevel {
	#if RELEASE
	return .none
	#else
	return .debug
	#endif
	}

func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
	#if !RELEASE
	if logLevelL.rawValue >= LegLevel.error.rawValue {
		let fileName = file.components(separatedBy: "/").last ?? kNoFileMessage
		print("\n💀 \(fileName), \(function) at line \(line) Error: \(message)\n")
	}
	#endif
}

func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
	#if !RELEASE
	if logLevelL.rawValue >= LegLevel.warning.rawValue {
		let fileName = file.components(separatedBy: "/").last ?? kNoFileMessage
		print("\n⚠️ \(fileName), \(function) at line \(line) Warning: \(message)\n")
	}
	#endif
}

func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
	#if !RELEASE
	if logLevelL.rawValue >= LegLevel.info.rawValue {
		let fileName = file.components(separatedBy: "/").last ?? kNoFileMessage
		print("\nℹ️ \(fileName), \(function) at line \(line) Info: \(message)\n")
	}
	#endif
}

func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
	#if DEBUG
	if logLevelL.rawValue >= LegLevel.debug.rawValue {
		let fileName = file.components(separatedBy: "/").last ?? kNoFileMessage
		print("\n👨‍💻 \(fileName), \(function) at line \(line) \(message)\n")
	}
	#endif
}

func logVerbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
	#if DEBUG
	if logLevelL.rawValue >= LegLevel.verbose.rawValue {
		let fileName = #file.components(separatedBy: "/").last ?? kNoFileMessage
		print("\n🗄 \(fileName), \(function) at line \(line) \(message)\n")
	}
	#endif
}

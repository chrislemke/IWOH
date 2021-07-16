/// Shared membership

import Foundation

public struct User {
	public let id: String
	public let lastLogin: Date

	public init(id: String, lastLogin: Date) {
		self.id = id
		self.lastLogin = lastLogin
	}
}

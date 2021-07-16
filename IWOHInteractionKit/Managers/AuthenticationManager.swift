import Foundation
import Firebase
import Combine

public struct AuthenticationManager {

	private let auth = Auth.auth()
	private let keychainGroup = "\(teamID).\(bundleIdentifier).SharedItems"

	// MARK: - Lifecycle
	public init() {}

	// MARK: - Public
	public var currentUserID: String? {
		auth.currentUser?.uid
	}

	public func signIn() -> AnyPublisher<String, Never> {
		return Future<String, Never> { promise in
			self.auth.signInAnonymously { authResult, _ in
				guard let authResult = authResult else {
					return
				}
				promise(.success(authResult.user.uid))
			}
		}.eraseToAnyPublisher()
	}

	public func configureAccessGroup() {
		do {
			try auth.useUserAccessGroup(keychainGroup)
		} catch let error as NSError {
			logError("Error changing user access group with error:\(error)!")
		}
	}
}

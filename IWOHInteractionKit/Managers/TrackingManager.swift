/// Shared membership

import Foundation
import Firebase

public struct TrackingManager {

	public enum EventName: String {

		/*
		A 'CTA' must only be used by buttons.
		A 'CTA' always has priority. So if an buttons opens a view 'CTA' should be used.
		All events should always use the past tense (exept 'CTA').
		*/

		case submitPostCTA = "submit_post_cta"
		case likePostCTA = "like_post_cta"
		case translatePostCTA = "translate_post_cta"
		case sharePostCTA = "share_post_cta"
		case closestPostCTA = "closesest_post_cta"
		case newestPostCTA = "newest_post_cta"
		case arCallOutOpened = "ar_call_out_opened"
		case mapCallOutOpened = "map_call_out_opened"
		case closestIntentCTA = "closest_intent_cta"
		case newestIntentCTA = "newest_intent_cta"
		case createPostIntentCTA = "create_post_intent_cta"
		case nearbyPostsIntentCTA = "nearby_posts_intent_cta"
	}

	public enum ScreenName: String {
		case list
		case map
		case ar
		case create
		case information
		case callOut = "call_out"
	}

	public static func track(_ name: EventName, parameters: [String: Any]? = nil) {
		#if !DEBUG
		Analytics.logEvent(name.rawValue, parameters: parameters)
		#elseif DEBUG
		logTracking(event: name)
		#endif
	}

	public static func track(_ screen: ScreenName) {
		#if !DEBUG
		Analytics.setScreenName(screen.rawValue, screenClass: nil)
		#elseif DEBUG
		logTracking(screen: screen)
		#endif
	}
}

#if DEBUG
extension TrackingManager {
	private static func logTracking(event: EventName, parameters: [String: Any]? = nil) {
		if let parameters = parameters {
			// swiftlint:disable:next line_length
			print("\n📝 'track(_ name:)' called with event: \(event.rawValue) and parameters: \(parameters). But nothing tracked!\n")
			return
		}
		print("\n📝 'track(_ name:)' called with event: \(event.rawValue). But nothing tracked!\n")
	}

	private static func logTracking(screen: ScreenName) {
		print("\n📝 'track(_ screen:)' called with screen: \(screen.rawValue). But nothing tracked!\n")
	}
}
#endif

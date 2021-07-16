import CoreSpotlight
import MobileCoreServices
import IWOHInteractionKit

struct SpotlightManager {

	static func indexItem(post: Post) {
		let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
		attributeSet.title = post.date.dateWithYear()
		attributeSet.contentDescription = post.message

		let item = CSSearchableItem(uniqueIdentifier: post.id.uuidString,
									domainIdentifier: domainIdentifier,
									attributeSet: attributeSet)
		CSSearchableIndex.default().indexSearchableItems([item]) { error in
			if let error = error {
				logError("Indexing error: \(error.localizedDescription)")
			}
		}
	}
}

import Foundation
import IWOHInteractionKit

#if DEBUG
struct Preview {
	// swiftlint:disable  line_length
	private static let post = Post(message: "preview.message".localized,
								   location: Location(latitude: 52.512904272743434,
													  longitude: 13.471657546130706,
													  altitude: 38.89),
								   heading: LocationHeading(trueHeading: 90),
								   date: Date(),
								   languageCode: "language.code".localized,
								   likes: 7, creatorID: "id")

	static let postViewModel = PostRowViewModel(post: post)
	static let postInformationViewModel = PostInformationViewModel(post: post, repository: Swinjector.shared.resolve(PostDetailsRepository.self))
	static let postCalloutViewModel =

		CalloutViewModel(post: post, repository: Swinjector.shared.resolve(PostDetailsRepository.self))

	static let appViewState = AppViewState()

	static var appViewStateStartupPresented: AppViewState {
		let appViewState = AppViewState()
		appViewState.isIntroductionPresented = true
		return appViewState
	}
}
#endif

import Foundation
import Combine
import IWOHInteractionKit

enum CurrentView {
	case list
	case map
}

enum QuickInformationSheet {
	case newest
	case closest
	case none
}

final class AppViewState: ObservableObject {
	@Published var currentView: CurrentView = .list
	@Published var presentedPost: Post?
	@Published var isCreatePostPresented: Bool = false
	@Published var isPostInformationPresented: Bool = false
	@Published var isQuickInformationPresented: Bool = false
	@Published var quickInformationSheet: QuickInformationSheet = .none
	@Published var isARViewPresented: Bool = false
	@Published var isIntroductionPresented: Bool = !UserDefaultsManager.hasSeenAppIntroduction {
		didSet {
			UserDefaultsManager.hasSeenAppIntroduction = !isIntroductionPresented
		}
	}
}

import SwiftUI
import Combine
import IWOHInteractionKit
import Intents

struct PostsListContentView: View {
	@EnvironmentObject private var appViewState: AppViewState
	@ObservedObject var viewModel: PostsListViewModel

	var body: some View {
		ZStack {
			Color.globalBackground
				.edgesIgnoringSafeArea(.all)
			PostsListView(viewModel: viewModel,
						  quickInformationSheet: $appViewState.quickInformationSheet,
						  isQuickInformationPresented: $appViewState.isQuickInformationPresented)
		}
		.onAppear {
			self.viewModel.requestLocation()
			TrackingManager.track(.list)
		}
		.sheet(isPresented: $appViewState.isQuickInformationPresented) {
			if self.viewModel.newestPost != nil && self.appViewState.quickInformationSheet == QuickInformationSheet.newest {
				Swinjector.shared.resolve(PostInformationContentView.self, argument: self.viewModel.newestPost!.post)
					.environmentObject(self.appViewState)
			} else if self.viewModel.closestPost != nil &&
				self.appViewState.quickInformationSheet == QuickInformationSheet.closest {
				Swinjector.shared.resolve(PostInformationContentView.self, argument: self.viewModel.closestPost!.post)
					.environmentObject(self.appViewState)
			} else if self.appViewState.presentedPost != nil {
				Swinjector.shared.resolve(PostInformationContentView.self, argument: self.appViewState.presentedPost!)
					.environmentObject(self.appViewState)
			}
		}
	}
}

private struct PostsListView: View {
	@ObservedObject var viewModel: PostsListViewModel
	@Binding var quickInformationSheet: QuickInformationSheet
	@Binding var isQuickInformationPresented: Bool

	var body: some View {
		VStack {
			List {
				ListTopView(viewModel: viewModel,
							quickInformationSheet: $quickInformationSheet,
							isQuickInformationPresented: $isQuickInformationPresented)
				ForEach(viewModel.postRowViewModels) { viewModel in
					ZStack {
						NavigationLink(destination:
							Swinjector.shared.resolve(PostInformationContentView.self, argument: viewModel.post),
									   label: { EmptyView() })

						PostRowView(viewModel: viewModel)
					}
				}
				.padding(.vertical, 20)
				.listRowBackground(Color.globalBackground)
				Rectangle()
					.frame(height: 100)
					.foregroundColor(.clear)
					.listRowBackground(Color.globalBackground)
			}
		}
	}
}

private struct ListTopView: View {
	@ObservedObject var viewModel: PostsListViewModel
	@Binding var quickInformationSheet: QuickInformationSheet
	@Binding var isQuickInformationPresented: Bool
	var body: some View {
		HStack {
			Spacer()
			VStack {
				HStack(spacing: 25) {
					TopViewButton(headlineTitle: "post.list.newest.button.text".localized,
								  bodyTitle: viewModel.newestPost?.dateWithoutYear ?? "",
								  disabled: viewModel.newestPost == nil,
								  action: {
									self.isQuickInformationPresented = true
									self.quickInformationSheet = .newest
									let intent = GetNewestPostIntent()
									intent.suggestedInvocationPhrase = "Get newest post"
									INInteraction(intent: intent, response: nil).donate(completion: nil)
									TrackingManager.track(.newestPostCTA)
					})

					TopViewButton(headlineTitle: "post.list.closest.button.text".localized,
								  bodyTitle: viewModel.closestPost?.distance.string ??
									"post.list.closest.no.location.text".localized,
								  disabled: viewModel.closestPost == nil,
								  action: {
									self.isQuickInformationPresented = true
									self.quickInformationSheet = .closest
									let intent = GetClosestPostIntent()
									intent.suggestedInvocationPhrase = "Get closest post"
									INInteraction(intent: intent, response: nil).donate(completion: nil)
									TrackingManager.track(.closestPostCTA)
					})
				}
				.modifier(Inlayed())
				.padding(.top, 8)
			}
			Spacer()
		}
		.listRowBackground(Color.globalBackground)
	}
}

private struct TopViewButton: View {
	let headlineTitle: String
	let bodyTitle: String
	let disabled: Bool
	let action: () -> ()

	var body: some View {
		Button(action: {
			self.action()
		}, label: {
			VStack {
				Text(headlineTitle)
					.font(.headline)
					.fontWeight(.heavy)
					.multilineTextAlignment(.center)
					.foregroundColor(disabled ? .buttonImageDisabled : .buttonImageEnabled)

				Text(bodyTitle)
					.font(.headline)
					.fontWeight(.regular)
					.multilineTextAlignment(.center)
					.foregroundColor(disabled ? .buttonImageDisabled : .buttonImageEnabled)
			}.padding(6)
		})
			.disabled(disabled)
			.buttonStyle(FlatRectangleButtonStyle())
	}
}

#if DEBUG
struct PostsListContentView_Previews: PreviewProvider {
	static var previews: some View {
		Swinjector.shared.resolve(PostsListContentView.self)
			.environmentObject(Swinjector.shared.resolve(AppViewState.self))
		.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

import SwiftUI

struct RootContentView: View {
	@EnvironmentObject private var appViewState: AppViewState
	let viewModel: RootViewModel
	let listview: PostsListContentView

	var body: some View {
		ZStack {
			NavigationView {
				VStack {
					Content(
						listView: listview,
						mapView: Swinjector.shared.resolve(PostsMapContentView.self))
						.environmentObject(self.appViewState)
				}
				.navigationBarTitle("")
				.navigationBarHidden(true)
				.navigationBarBackButtonHidden(true)
			}
			.zIndex(0)
			FooterView()
				.zIndex(1)
			if appViewState.isIntroductionPresented {
				Swinjector.shared.resolve(IntroductionContentView.self)
					.zIndex(2)
					.offset(y: 45)
					.transition(.move(edge: .bottom))
			} else if appViewState.isARViewPresented {
				Swinjector.shared.resolve(PostsARContentView.self)
					.zIndex(2)
					.offset(y: 45)
					.transition(.move(edge: .bottom))
			}
		}
		.sheet(isPresented: self.$appViewState.isCreatePostPresented) {
			Swinjector.shared.resolve(CreatePostContentView.self)
				.environmentObject(self.appViewState)
		}
	}
}

private struct Content: View {
	@EnvironmentObject var appViewState: AppViewState
	let listView: PostsListContentView
	let mapView: PostsMapContentView

	var body: some View {
		view
	}

	@ViewBuilder
	private var view: some View {
		if appViewState.currentView == .list {
			listView.environmentObject(self.appViewState)
		} else {
			mapView
		}
	}
}

private struct FooterView: View {
	@EnvironmentObject private var appViewState: AppViewState
	@State private var angle: Double = 0

	var body: some View {
		VStack(alignment: .center) {
			if appViewState.isPostInformationPresented == false {
				Spacer()
				HStack(spacing: 15) {
					switchViewButton
					openARViewButton
					openCreatePostToggle
				}
				.frame(width: 275, height: 100)
				.background(Color.globalFill)
				.cornerRadius(25)
				.shadow(color: Color.globalBottomShadow, radius: 10, x: 10, y: 10)
				.shadow(color: Color.globalTopShadow, radius: 10, x: -3, y: -3)
				.transition(.move(edge: .bottom))
				.animation(.default)
			}
		}
		.padding(.bottom, 10)
	}

	private var openCreatePostToggle: some View {
		Toggle(isOn: self.$appViewState.isCreatePostPresented) {
			Image(systemName: "square.and.pencil")
				.frame(width: 17, height: 12)
				.foregroundColor(.buttonImageEnabled)
		}
		.toggleStyle(SimpleToggleStyle())
	}

	private var openARViewButton: some View {
		Button(action: {
			self.$appViewState.isARViewPresented.animation().wrappedValue = true
		}, label: {
			Image(systemName: "perspective")
				.frame(width: 17, height: 12)
				.foregroundColor(.buttonImageEnabled)
		})
			.buttonStyle(SimpleCircleButtonStyle())
	}

	private var switchViewButton: some View {
		Button(action: {
			self.angle += 90
			if self.appViewState.currentView == .map {
				self.appViewState.currentView = .list
			} else {
				self.appViewState.currentView = .map
			}
		}, label: {
			Image(systemName: buttonImageName)
				.frame(width: 17, height: 12)
				.foregroundColor(.buttonImageEnabled)
				.rotationEffect(Angle(degrees: angle))
				.animation(.easeIn)
		})
			.buttonStyle(SimpleCircleButtonStyle())
	}

	private var buttonImageName: String {
		switch appViewState.currentView {
			case .map:
				return "rectangle.split.3x1"
			case .list:
				return "map"			
		}
	}
}

#if DEBUG
struct GlobalContentView_Previews: PreviewProvider {
	static var previews: some View {
		Swinjector.shared.resolve(RootContentView.self)
			.environmentObject(Swinjector.shared.resolve(AppViewState.self))
	}
}
#endif

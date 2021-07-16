import SwiftUI
import IWOHInteractionKit

struct IntroductionContentView: View, Testable {

	// For testing
	var inspection = Inspection<Self>()

	@EnvironmentObject private var appViewState: AppViewState
	@ObservedObject var viewModel: IntroductionViewModel
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				Spacer()
				VStack {
					HeadlinesView()
					IntroductionText()
					FeaturesView()
					IntroductionButtons(locationAuthenticationStatus: self.viewModel.locationAuthenticationStatus,
										isLocationServiceToggleTapped: self.$viewModel.isLocationServiceToggleTapped,
										isNotificationRequestButtonTapped: self.$viewModel.isNotificationRequestToggleTapped)
					Spacer(minLength: 60)
				}
				.frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.98)
				.background(Color.startupBackground)
				.cornerRadius(25)
				.shadow(color: .gray, radius: 8, x: -3, y: -3)
			}
		}.onReceive(inspection.notice) { self.inspection.visit(self, $0) }
	}

	private struct HeadlinesView: View {
		var body: some View {
			VStack {
				Text("introduction.headline")
					.foregroundColor(.startupText)
					.font(.system(.largeTitle))
					.fontWeight(.heavy)
					.padding(.top, 20)

				Text("introduction.subtitle")
					.foregroundColor(.startupText)
					.font(.system(.headline))
					.fontWeight(.bold)
			}
		}
	}

	private struct IntroductionText: View {
		var body: some View {
			Text(DeviceManager.isSmallOrMediumDevice() ? "introduction.text.short" : "introduction.text.long")
				.foregroundColor(.startupText)
				.font(.system(.subheadline))
				.fontWeight(.semibold)
				.multilineTextAlignment(.leading)
				.padding(17)
		}
	}

	private struct FeaturesView: View {
		var body: some View {
			VStack {
				FeatureView(imageName: "text.bubble",
							text:
					DeviceManager.isSmallOrMediumDevice() ?
						"introduction.first.feature.text.short" :
					"introduction.first.feature.text.long")
				FeatureView(imageName: "location.circle",
							text:
					DeviceManager.isSmallOrMediumDevice() ? "introduction.second.feature.text.short" :
					"introduction.second.feature.text.long")
				Spacer()
			}
		}
	}

	private struct FeatureView: View {
		let imageName: String
		let text: String
		var body: some View {
			HStack {
				Image(systemName: imageName)
					.foregroundColor(.startupText)
					.font(.system(.largeTitle))
					.frame(width: 34, height: 24)

				Text(LocalizedStringKey(text))
					.foregroundColor(.startupText)
					.font(.system(.headline))
					.fontWeight(.semibold)
					.multilineTextAlignment(.leading)
					.padding(.leading, 5)
			}
			.padding(.horizontal, 17)
		}
	}
}

struct IntroductionButtons: View {
	let locationAuthenticationStatus: LocationAuthenticationStatus
	@Binding var isLocationServiceToggleTapped: Bool
	@Binding var isNotificationRequestButtonTapped: Bool
	@EnvironmentObject private var appViewState: AppViewState
	var body: some View {
		HStack(spacing: 30) {

			Toggle(isOn: self.$isLocationServiceToggleTapped, label: {
				Image(systemName: self.locationToggleImageName())
					.foregroundColor(.buttonImageEnabled)
			})
				.disabled(isLocationToogleDisabled())
				.toggleStyle(SimpleToggleStyle())


			Toggle(isOn: self.$isNotificationRequestButtonTapped, label: {
				Image(systemName: self.isNotificationRequestButtonTapped ? "envelope.badge.fill" : "envelope.badge")
					.foregroundColor(.buttonImageEnabled)
			}).toggleStyle(SimpleToggleStyle())

			Button(action: {
				self.$appViewState.isIntroductionPresented.animation(Animation.easeInOut).wrappedValue = false
			}, label: {
				Image(systemName: "xmark")
					.foregroundColor(.buttonImageEnabled)
			}).buttonStyle(SimpleCircleButtonStyle())
		}
	}

	func locationToggleImageName() -> String {
		switch self.locationAuthenticationStatus {
			case .authorizedWhenInUse: return "location.fill"
			case .notDetermined: return "location"
			case .denied, .restricted: return "location.slash"
		}
	}

	private func isLocationToogleDisabled() -> Bool {
		switch locationAuthenticationStatus {
			case .authorizedWhenInUse, .denied, .restricted:
				return true
			case .notDetermined: return false
		}
	}
}

#if DEBUG
struct StartupContentView_Previews: PreviewProvider {
	static var previews: some View {
		Swinjector.shared.resolve(RootContentView.self)
			.environmentObject(Preview.appViewStateStartupPresented)
			.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

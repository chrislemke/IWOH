import SwiftUI

struct PostRowView: View {

	@ObservedObject var viewModel: PostRowViewModel

	var body: some View {
		VStack {
			VStack(alignment: .leading, spacing: 10) {
				NonLocalizedIconLabelView(text: viewModel.distance.string, imageTitle: "mappin.circle", color: .globalLabelText)
				NonLocalizedIconLabelView(text: viewModel.dateWithYear, imageTitle: "calendar.circle", color: .globalLabelText)
			}
			Spacer(minLength: 5)
			PostMessageTextField(message: viewModel.originalMessage, padding: 20)
			Spacer(minLength: 5)

		}
		.buttonStyle(PlainButtonStyle())
		.padding(10)
		.frame(width: 300)
		.background(Color.globalFill)
		.cornerRadius(25)
		.shadow(color: .globalBottomShadow, radius: 10, x: 10, y: 10)
		.shadow(color: .globalTopShadow, radius: 10, x: -3, y: -3)
	}
}

#if DEBUG
struct PostRowView_Previews: PreviewProvider {
	static var previews: some View {
		Swinjector.shared.resolve(PostRowView.self)
			.environment(\.locale, .init(identifier: "language.code".localized))
	}
}
#endif

import SwiftUI

struct PostInformationView: View {

	@ObservedObject var viewModel: PostInformationViewModel
    @State private var translateToggleIsOn: Bool = false
    @State private var isSharePresented: Bool = false

	var body: some View {
		VStack {
			HStack(spacing: 20) {
				NonLocalizedIconLabelView(text: viewModel.distance.string,
										  imageTitle: "mappin.circle",
										  color: .postDetailsIconLabel)
				NonLocalizedIconLabelView(text: viewModel.dateWithYear,
										  imageTitle: "calendar.circle",
										  color: .postDetailsIconLabel)
			}
			.padding(.top, 15)
			PostMessageTextField(message: translateToggleIsOn ?
				viewModel.translatedMessage : viewModel.originalMessage, padding: 10)

			Spacer()
			PostDetailInlayButtonView(likeButtonAction: viewModel.likePost,
									  likes: viewModel.likes,
									  translateToggleIsOn: $translateToggleIsOn,
                                      translateToogleDisabled: !viewModel.shouldProvideTranslation,
									  likeButtonDisabled: $viewModel.likingDisabled,
									  shareButtonPressed: $isSharePresented)
				.padding(.bottom, 30)
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.onAppear {
			self.viewModel.assignToLikes()
		}
		.frame(maxWidth: .infinity,
			   maxHeight: 360,
			   alignment: .center)
			.background(Color.postDetailsViewBackground)
			.sheet(isPresented: $isSharePresented, content: {
				ActivityView(activityItems: [self.viewModel.originalMessage],
									   location: self.viewModel.location)
			})
	}
}

#if DEBUG
struct PostDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		PostInformationContentView(viewModel: Preview.postInformationViewModel).environmentObject(AppViewState())
	}
}
#endif

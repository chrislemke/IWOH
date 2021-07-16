import SwiftUI
import Swinject
import IWOHInteractionKit

struct Swinjector {

	static let shared = Swinjector()
	private let container = Container()

	// MARK: - Lifecycle
	private init() {
		registerManagers()
		registerAppState()
		registerRootModule()
		registerStartupModule()
		registerCreatePostModule()
		registerPostsARModule()
		registerPostsListModule()
		registerPostsMapModule()
		registerPostInformationModule()
	}

	// MARK: - Public
	func resolve<SERVICE>(_ service: SERVICE.Type) -> SERVICE {
		guard let service = container.resolve(service) else {
			fatalError("Could not resolve \(SERVICE.self)!")
		}
		return service
	}

	func resolve<SERVICE, ARGUMENT>(_ service: SERVICE.Type, argument: ARGUMENT) -> SERVICE {
		guard let service = container.resolve(service, argument: argument) else {
			fatalError("Could not resolve \(SERVICE.self)!")
		}
		return service
	}

	func resolve<SERVICE, ARGUMENT, ARGUMENT2>(_ service: SERVICE.Type,
											   argument: ARGUMENT,
											   _ argument2: ARGUMENT2) -> SERVICE {
		guard let service = container.resolve(service, arguments: argument, argument2) else {
			fatalError("Could not resolve \(SERVICE.self)!")
		}
		return service
	}

	// MARK: - Register
	private func registerManagers() {

		container.register(MLManager.self) { _ in
			MLManager()
		}.inObjectScope(.container)

		container.register(AuthenticationManager.self) { _ in
			AuthenticationManager()
		}.inObjectScope(.container)

		container.register(FirestoreManager.self) { _ in
			FirestoreManager()
		}.inObjectScope(.container)

		container.register(LocationManager.self) { _ in
			LocationManager()
		}.inObjectScope(.container)

		container.register(UserManager.self) { _ in
			UserManager()
		}.inObjectScope(.container)

		container.register(PushNotificationManager.self) {
			PushNotificationManager(userManager: $0.resolve(UserManager.self)!)
		}

		container.register(UserDefaultsManager.self) { _ in
			UserDefaultsManager()
		}
	}

	private func registerAppState() {
		container.register(AppViewState.self) { _ in
			AppViewState()
		}
	}

	private func registerRootModule() {

		container.register(RootRepository.self) { _ in
			RootRepository()
		}

		container.register(RootViewModel.self) { _ in
			RootViewModel()
		}

		container.register(RootContentView.self) {
			RootContentView(viewModel: $0.resolve(RootViewModel.self)!,
							listview: $0.resolve(PostsListContentView.self)!)
		}
	}

	private func registerStartupModule() {

		container.register(IntroductionRepository.self) {
			IntroductionRepository(locationManager: $0.resolve(LocationManager.self)!,
								   userDefaultsManager: $0.resolve(UserDefaultsManager.self)!,
								   pushNotificationManager: $0.resolve(PushNotificationManager.self)!)
		}

		container.register(IntroductionViewModel.self) {
			IntroductionViewModel(repository: $0.resolve(IntroductionRepository.self)!)
		}

		container.register(IntroductionContentView.self) {
			IntroductionContentView(viewModel: $0.resolve(IntroductionViewModel.self)!)
		}
	}

	private func registerPostsListModule() {

		container.register(PostRowRepository.self) {
			PostRowRepository(locationManager: $0.resolve(LocationManager.self)!)
		}

		container.register(PostsListContentView.self) {
			PostsListContentView(viewModel: $0.resolve(PostsListViewModel.self)!)
		}

		container.register(PostsListRepository.self) {
			PostsListRepository(firestoreManager: $0.resolve(FirestoreManager.self)!,
								authenticationManager: $0.resolve(AuthenticationManager.self)!,
								locationManager: $0.resolve(LocationManager.self)!)
		}

		container.register(PostsListViewModel.self) {
			PostsListViewModel(repository: $0.resolve(PostsListRepository.self)!)
		}
	}

	private func registerCreatePostModule() {

		container.register(CreatePostRepositoryTyp.self) {
			CreatePostRepository(locationManager: $0.resolve(LocationManager.self)!,
								 firestoreManager: $0.resolve(FirestoreManager.self)!,
								 mlManager: $0.resolve(MLManager.self)!,
								 userManager: $0.resolve(UserManager.self)!,
								 authenticationManager: $0.resolve(AuthenticationManager.self)!)
		}

		container.register(CreatePostViewModel.self) {
			CreatePostViewModel(repository: $0.resolve(CreatePostRepositoryTyp.self)!)
		}

		container.register(CreatePostContentView.self) {
			CreatePostContentView(viewModel: $0.resolve(CreatePostViewModel.self)!)
		}
	}

	private func registerPostsARModule() {
		container.register(PostsARRepository.self) {
			PostsARRepository(firestoreManager: $0.resolve(FirestoreManager.self)!)
		}

		container.register(PostsARViewModel.self) {
			PostsARViewModel(repository: $0.resolve(PostsARRepository.self)!)
		}

		container.register(PostsARContentView.self) {
			PostsARContentView(viewModel: $0.resolve(PostsARViewModel.self)!)
		}

		container.register(PostARAnnotationRepository.self) {
			PostARAnnotationRepository(locationManager: $0.resolve(LocationManager.self)!)
		}

		container.register(PostARAnnotationViewModel.self) { (resolver: Resolver, post: Post) in
			PostARAnnotationViewModel(post: post, repository: resolver.resolve(PostARAnnotationRepository.self)!)
		}
	}

	private func registerPostsMapModule() {

		container.register(CallOutView.self) { (resolver: Resolver, post: Post, isCallOutPresented: Binding<Bool>) in
			CallOutView(
				viewModel: resolver.resolve(CalloutViewModel.self,
											arguments: post, resolver.resolve(PostDetailsRepositoryTyp.self)!)!,
				isCallOutPresented: isCallOutPresented
			)
		}

		container.register(CalloutViewModel.self) { (_, post: Post, repository: PostDetailsRepositoryTyp) in
			CalloutViewModel(post: post, repository: repository)
		}

		container.register(PostsMapContentView.self) {
			PostsMapContentView(viewModel: $0.resolve(PostsMapViewModel.self)!)
		}

		container.register(PostsMapRepository.self) {
			PostsMapRepository(locationManager: $0.resolve(LocationManager.self)!,
							   firestoreManager: $0.resolve(FirestoreManager.self)!)
		}

		container.register(PostsMapViewModel.self) {
			PostsMapViewModel(repository: $0.resolve(PostsMapRepository.self)!)
		}
	}

	private func registerPostInformationModule() {

		container.register(PostInformationContentView.self) { (resolver: Resolver, post: Post) in
			PostInformationContentView(viewModel: resolver.resolve(PostInformationViewModel.self, argument: post)!)
		}

		container.register(PostInformationViewModel.self) { (resolver: Resolver, post: Post) in
			PostInformationViewModel(post: post, repository: resolver.resolve(PostDetailsRepositoryTyp.self)!)
		}

		container.register(PostDetailsRepositoryTyp.self) {
			PostDetailsRepository(locationManager: $0.resolve(LocationManager.self)!,
								  userManager: $0.resolve(UserManager.self)!,
								  firestoreManager: $0.resolve(FirestoreManager.self)!)
		}
	}
}

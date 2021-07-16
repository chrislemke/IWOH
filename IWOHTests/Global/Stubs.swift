import Combine
import CombineTestExtensions
import IWOHInteractionKit
@testable import IWOH

struct MLManagerStub: MLManagerTyp {

	let scheduler: TestScheduler

	func detectLanguage(for text: String) -> AnyPublisher<String, Never> {
		TestPublisher(scheduler, [(100, .value(TestValues.languageCode))]).eraseToAnyPublisher()
	}
}

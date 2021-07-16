import Combine

public protocol MLManagerTyp {

	func detectLanguage(for text: String) -> AnyPublisher<String, Never>
}

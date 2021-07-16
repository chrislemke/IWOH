import Firebase
import Combine

public struct MLManager: MLManagerTyp {

	private let naturalLanguage = NaturalLanguage.naturalLanguage()

	// MARK: - Lifecycle
	public init() {}

	// MARK: - Public
	public func detectLanguage(for text: String) -> AnyPublisher<String, Never> {
		return Future<String, Never> {  promise in
			let languageId = self.naturalLanguage.languageIdentification()
			languageId.identifyLanguage(for: text) { languageCode, _  in
				if let languageCode = languageCode, languageCode != "und" {
					promise(.success(languageCode))
					return
				}
				promise(.success(""))
			}
		}.eraseToAnyPublisher()
	}
}

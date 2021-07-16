import Combine

/// @mockable
public protocol FirestoreManagerTyp {

	func documentPath<MODEL: Storeable>(_ type: MODEL.Type, id: String) -> String

	func updateData<MODEL: Storeable>(_ type: MODEL.Type,
									  id: String,
									  data: [MODEL.CollectionFields: Any]) -> AnyPublisher<Bool, Never>

	func addReferenceToSubcollection<MODEL: Subcollectable>(sourceType: MODEL.Type,
															id: String,
															referencedID: String,
															referencedDocumentPath: String,
															subcollectionPath: MODEL.SubcollectionPath) -> AnyPublisher<Bool, Never>

	func add<MODEL: Storeable>(_ object: MODEL) -> AnyPublisher<SubmissionState, Never>

	func isDocumentExistingInSubcollection<MODEL: Subcollectable>(_ type: MODEL.Type,
																  id: String,
																  documentID: String,
																  subcollectionPath: MODEL.SubcollectionPath) -> AnyPublisher<Bool, Never>

	func get<MODEL: Storeable>(_ type: MODEL.Type, id: String) -> AnyPublisher<MODEL, Never>

	func listen<MODEL: Storeable>(_ type: MODEL.Type,
								  order: Order<MODEL>) -> AnyPublisher<[MODEL], Never>
}

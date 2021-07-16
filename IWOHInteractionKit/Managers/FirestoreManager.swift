import Firebase
import FirebaseFirestoreSwift
import Combine

public enum SubmissionState {
	case success(String)
	case error(Error?)
	case unspecified
}

public struct Order<MODEL: Storeable> {
	public let field: MODEL.CollectionFields
	public let descending: Bool

	public init(field: MODEL.CollectionFields, descending: Bool) {
		self.field = field
		self.descending = descending
	}
}

struct FirestoreError: Error {
	let message: String
	let wrappedError: Error?

	init(message: String, error: Error? = nil) {
		self.message = message
		self.wrappedError = error
	}
}

public struct FirestoreManager: FirestoreManagerTyp {

	private let database = Firestore.firestore()

	// MARK: - Lifecycle
	public init() {
		let settings = FirestoreSettings()
		settings.isPersistenceEnabled = true
		self.database.settings = settings
	}

	// MARK: - Document path
	public func documentPath<MODEL: Storeable>(_ type: MODEL.Type, id: String) -> String {
		return database
			.collection(MODEL.collectionPath)
			.document(id)
			.path
	}

	// MARK: - Update
	public func updateData<MODEL: Storeable>(_ type: MODEL.Type,
									  id: String,
									  data: [MODEL.CollectionFields: Any]) -> AnyPublisher<Bool, Never> {
		Future<Bool, Never> { promise in
			let newData = Dictionary(uniqueKeysWithValues:
				data.map { (key: MODEL.CollectionFields, value: Any) in
					(key.rawValue, value)
			})
			self.database
				.collection(MODEL.collectionPath)
				.document(id)
				.updateData(newData, completion: { error in
					if error == nil {
						logInfo("Successfully updated document with ID: \(id), path: \(MODEL.collectionPath).")
						promise(.success(true))
					}
				})
		}.eraseToAnyPublisher()
	}

	public func addReferenceToSubcollection<MODEL: Subcollectable>(sourceType: MODEL.Type,
															id: String,
															referencedID: String,
															referencedDocumentPath: String,
															subcollectionPath: MODEL.SubcollectionPath) -> AnyPublisher<Bool, Never> {
		Future<Bool, Never> { promise in
			let referencedDocument = self.database
				.document("\(referencedDocumentPath)")

			let data = [subcollectionPath.rawValue: referencedDocument]

			self.database
				.collection(MODEL.collectionPath) // users
				.document(id)
				.collection(subcollectionPath.rawValue)
				.document(referencedID)
				.setData(data) { error in
					if let error = error {
						let firestoreError = FirestoreError(message: "Could not add data to Firestore. Error: \(error)!", error: error)
						promise(.success(false))
						logError(firestoreError.message)
						return
					}
					promise(.success(true))
					logInfo("Successfully referenced document with ID: \(referencedID), path: \(referencedDocumentPath).")
			}
		}.eraseToAnyPublisher()
	}

	// MARK: - Add
	public func add<MODEL: Storeable>(_ object: MODEL) -> AnyPublisher<SubmissionState, Never> {
		return Future<SubmissionState, Never> { promise in

			guard let data = try? Firestore.Encoder().encode(object) else {
				let error = FirestoreError(message: "Could not encode 'object': \(object)")
				promise(.success(.error(error)))
				logError(error.message)
				return
			}
			self.database
				.collection(MODEL.collectionPath)
				.document(object.id)
				.setData(data) { error in
					if let error = error {
						let firestoreError = FirestoreError(message: "Could not add data to Firestore. Error: \(error)!", error: error)
						promise(.success(.error(firestoreError)))
						logError(firestoreError.message)
					}
					logInfo("Successfully added document with ID: \(object.id), path: \(MODEL.collectionPath).")
					promise(.success(.success(object.id)))
			}
		}.eraseToAnyPublisher()
	}

	// MARK: - Check for  existence in subcollection
	public func isDocumentExistingInSubcollection<MODEL: Subcollectable>(_ type: MODEL.Type,
																id: String,
																documentID: String,
																subcollectionPath: MODEL.SubcollectionPath)
																-> AnyPublisher<Bool, Never> {
		return Future<Bool, Never> { promise in
			self.database
				.collection(MODEL.collectionPath)
				.document(id)
				.collection(subcollectionPath.rawValue)
				.document(documentID)
				.getDocument { document, _ in
					promise(.success(document?.exists ?? false))
			}
		}.eraseToAnyPublisher()
	}

	// MARK: - Get
	public func get<MODEL: Storeable>(_ type: MODEL.Type, id: String) -> AnyPublisher<MODEL, Never> {
		return Future<MODEL, Never> { promise in
			self.database
				.collection(MODEL.collectionPath)
				.document(id)
				.getDocument(completion: { document, error in
					if let error = error {
						logError("Error getting documents: \(error)!")
						return
					}
					if let document = document, let data = document.data(),
						let firestorePost = try? Firestore.Decoder()
							.decode(type.self, from: data) {
						logInfo("Successfully get document with ID: \(id), path: \(MODEL.collectionPath).")
						promise(.success(firestorePost))
					}
				})
		}
		.eraseToAnyPublisher()
	}

	public func get<MODEL: Storeable>(_ type: MODEL.Type, query: Query) -> AnyPublisher<[MODEL], Never> {
		return Future<[MODEL], Never> { promise in
			query
				.getDocuments(completion: { snapshot, _ in
					
					guard let snapshot = snapshot else {
						promise(.success([]))
						return
					}
					let documents = snapshot.documents.compactMap { document -> MODEL? in
						print(document)
						if let document = try? Firestore.Decoder().decode(MODEL.self, from: document.data()) {
							logInfo("Successfully get document: \(document)!")
							return document
						}
						return nil
					}
					promise(.success(documents))
				})
		}
		.eraseToAnyPublisher()
	}

	// MARK: - Listener 
	public func listen<MODEL: Storeable>(_ type: MODEL.Type,
								  order: Order<MODEL>) -> AnyPublisher<[MODEL], Never> {

		let subject = CurrentValueSubject<[MODEL], Never>([])

		self.simpleQuery(MODEL.self, order: order, limit: 100)
			.addSnapshotListener { snapshot, _ in
				guard let snapshot = snapshot else {
					subject.send([])
					return
				}
				let documents = snapshot.documents.compactMap { document -> MODEL? in
					if let document = try? Firestore.Decoder().decode(type.self, from: document.data()) {
						return document
					}
					return nil
				}
				subject.send(documents)
			}
			return subject.eraseToAnyPublisher()
		}

	// MARK: - Queries
	public func simpleQuery<MODEL: Storeable>(_ type: MODEL.Type,
										 order: Order<MODEL>,
										 limit: Int) -> Query {
		return database
			.collection(MODEL.collectionPath)
			.order(by: order.field.rawValue, descending: order.descending)
			.limit(to: limit)
	}

	public func rangeQuery<MODEL: Storeable>(_ type: MODEL.Type,
									  isGreaterThanEqualTo: Any,
									  isLessThan: Any,
									  field: MODEL.CollectionFields,
								 limit: Int) -> Query {
		return database
			.collection(MODEL.collectionPath)
			.whereField(field.rawValue, isGreaterThanOrEqualTo: isGreaterThanEqualTo)
			.whereField(field.rawValue, isLessThan: isLessThan)
			.limit(to: limit)
	}
}

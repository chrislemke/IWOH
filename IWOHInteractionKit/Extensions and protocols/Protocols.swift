import Foundation

public protocol Storeable: Codable {
	associatedtype CollectionFields: RawRepresentable where CollectionFields.RawValue == String

	static var collectionPath: String { get }
	var id: String { get }
}

public protocol Subcollectable: Storeable {
	associatedtype SubcollectionPath: RawRepresentable where SubcollectionPath.RawValue == String
}

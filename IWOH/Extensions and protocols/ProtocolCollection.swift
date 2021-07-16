import Foundation
import SwiftUI
import IWOHInteractionKit

protocol AnnotationTyp {
	var post: Post { get }
}

protocol Testable: View {

	/*
	For using this protocol  '.onReceive(inspection.notice) { self.inspection.visit(self, $0) }'
	needs to be add the body of the view.
	*/

	associatedtype ViewTyp: View
	var inspection: Inspection<ViewTyp> { get }
}

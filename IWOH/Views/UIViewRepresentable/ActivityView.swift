import SwiftUI
import UIKit
import IWOHInteractionKit

struct ActivityView: UIViewControllerRepresentable {

	var activityItems: [Any]
	var applicationActivities = [UIActivity]()
	var location: Location

	// swiftlint:disable colon
	// MARK: - UIViewControllerRepresentable
	func makeUIViewController(context:
		UIViewControllerRepresentableContext<ActivityView>) ->
		UIActivityViewController {
			guard let controller = activityViewControllerWithLocation(activityItems: activityItems,
																	  applicationActivities: applicationActivities) else {
				return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
			}
			return controller
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController,
								context:
		UIViewControllerRepresentableContext<ActivityView>) {}

	// MARK: - Private
	private func activityViewControllerWithLocation(activityItems: [Any],
													applicationActivities: [UIActivity]) -> UIActivityViewController? {
		var shareItems = [Any]()

		guard let cachesPathString = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
			logError("Error: couldn't find the caches directory!")
			return nil
		}
		let URLString = "https://maps.apple.com?ll=\(location.latitude),\(location.longitude)"

		if let url = NSURL(string: URLString) {
			shareItems.append(url)
		}

		let locationTitle = "\(String(format: "%.8f", location.latitude)), \(String(format: "%.8f", location.longitude))"

		let vCardString = [
			"BEGIN:VCARD",
			"VERSION:3.0",
			"PRODID:-//IWOH//EN",
			"N:;\(locationTitle);;;",
			"FN:\(locationTitle)",
			"item1.URL;type=pref:\(URLString)",
			"item1.X-ABLabel:map url",
			"END:VCARD"
			].joined(separator: "\n")

		let vCardFilePath = (cachesPathString as NSString).appendingPathComponent("\(locationTitle).loc.vcf")
		let nsVCardData = NSURL(fileURLWithPath: vCardFilePath)
		shareItems.append(nsVCardData)
		shareItems.append(contentsOf: activityItems)

		do {
			try vCardString.write(toFile: vCardFilePath, atomically: true, encoding: String.Encoding.utf8)
			let activityViewController = UIActivityViewController(activityItems: shareItems,
																  applicationActivities: applicationActivities)
			activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print,
															UIActivity.ActivityType.assignToContact,
															UIActivity.ActivityType.saveToCameraRoll,
															UIActivity.ActivityType.postToVimeo,
															UIActivity.ActivityType.postToTencentWeibo,
															UIActivity.ActivityType.postToWeibo]
			return activityViewController
		} catch let error {
			logError("Error, \(error), saving vCard: \(vCardString) to file path: \(vCardFilePath).")
			return nil
		}
	}
}

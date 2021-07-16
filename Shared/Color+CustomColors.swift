import SwiftUI
import UIKit

extension Color {

	// MARK: - Global
	static let globalText = Color("global.text.color")
	static let globalLabelText = Color("global.label.text.color")
	static let globalBackground = Color("global.background.color")
	static let globalFill = Color("global.background.color")
	static let globalTopShadow = Color("global.top.shadow.color")
	static let globalBottomShadow = Color("global.bottom.shadow.color")
	static let globalInlayShadowTop = Color("global.inlay.gradient.top.shadow.color")
	static let globalInlayShadowBottom = Color("global.inlay.gradient.bottom.shadow.color")
	static let globalInlayStoke = Color("global.inlay.stroke.color")

	// MARK: - Startup
	static let startupBackground = Color("global.indicator.color")
	static let startupText = Color("startup.text.color")

	// MARK: - Buttons
	static let buttonPressedInlayStroke = Color("button.pressed.inlay.stroke.color")
	static let buttonImageEnabled = Color("global.indicator.color")
	static let buttonImageDisabled = Color("button.image.disabled.color")

	// MARK: - PostDetailsContentView
	static let postDetailsViewBackground = Color("global.background.color")
	static let closingIndicatorForeground = Color("global.indicator.color")
	static let postDetailsIconLabel = Color("icon.map.overlay.color")

	// MARK: - CreatePostContentView

	static let postButtonBackgroundActiveState = Color("button.active.background.green")
	static let postButtonForgroundActiveState = Color("button.active.foreground.color")
	static let createPostTextViewFrameStroke = Color("map.street.border.color")
}

extension UIColor {

	// MARK: - Global
	static let globalBackground = UIColor(named: "global.background.color")
	static let globalText = UIColor(named: "global.text.color")

	// MARK: - MapView
	static let annotationView = UIColor(named: "global.indicator.color")
	static let annotationGlyph = UIColor(named: "global.background.color")
	static let locationIndicator = UIColor(named: "global.indicator.color")

	// MARK: - ARAnnotation
	static let annotationForeground = UIColor(named: "global.indicator.color")
}

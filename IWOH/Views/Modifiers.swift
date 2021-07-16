import SwiftUI

struct Inlayed: ViewModifier {
	func body(content: Content) -> some View {
		content
			.padding(.horizontal, 40)
			.padding(.vertical, 15)
			.overlay(
				Rectangle()
					.stroke(Color.black, lineWidth: 4)
					.blur(radius: 4)
					.offset(x: 2, y: 2)
					.cornerRadius(15)
					.mask(Rectangle().fill(LinearGradient(.globalInlayShadowTop, .globalInlayShadowBottom))))
			.overlay(
				Rectangle()
					.stroke(Color.globalInlayStoke, lineWidth: 8)
					.blur(radius: 4)
					.offset(x: -2, y: -2)
					.cornerRadius(15)
					.mask(Rectangle().fill(LinearGradient(.clear, .globalInlayShadowBottom))))
	}
}

import SwiftUI

struct SimpleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            configuration.label
                .padding(30)
                .contentShape(Circle())
        })
            .background(
                SimpleBackground(isHighlighted: configuration.isOn, shape: Circle()))
    }
}

struct SimpleCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                SimpleBackground(isHighlighted: configuration.isPressed, shape: Circle()))
    }
}

struct SimpleRectangleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .contentShape(Rectangle())
            .background(SimpleBackground(isHighlighted: configuration.isPressed, shape: Rectangle(), cornerRadius: 8))
    }
}

struct FlatRectangleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .contentShape(Rectangle())
            .background(FlatBackground(isHighlighted: configuration.isPressed, shape: Rectangle(), cornerRadius: 8))
    }
}

struct FlatRectangleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            configuration.label
                .padding(2)
                .contentShape(Rectangle())
        })
             .background(FlatBackground(isHighlighted: configuration.isOn, shape: Rectangle(), cornerRadius: 8))
    }
}

private struct SimpleBackground<SHAPE: Shape>: View {
    var isHighlighted: Bool
    var shape: SHAPE
    var cornerRadius: CGFloat = 0.0
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.globalFill)
                    .overlay(
                        shape
                            .stroke(Color.black, lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .cornerRadius(cornerRadius)
                            .mask(shape.fill(LinearGradient(Color.black, Color.clear))))
                    .overlay(
                        shape
                            .stroke(Color.buttonPressedInlayStroke, lineWidth: 8)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .cornerRadius(cornerRadius)
                            .mask(shape.fill(LinearGradient(Color.clear, Color.black))))
            } else {
                shape
                    .fill(Color.globalFill)
                    .cornerRadius(cornerRadius)
                    .shadow(color: Color.globalBottomShadow, radius: 10, x: 10, y: 10)
                    .shadow(color: Color.globalTopShadow, radius: 10, x: -3, y: -3)
            }
        }
    }
}

private struct FlatBackground<SHAPE: Shape>: View {
    var isHighlighted: Bool
    var shape: SHAPE
    var cornerRadius: CGFloat = 0.0
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.globalFill)
                    .overlay(
                        shape
                            .stroke(Color.black, lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .cornerRadius(cornerRadius)
                            .mask(shape.fill(LinearGradient(Color.black, Color.clear))))
                    .overlay(
                        shape
                            .stroke(Color.buttonPressedInlayStroke, lineWidth: 8)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .cornerRadius(cornerRadius)
                            .mask(shape.fill(LinearGradient(Color.clear, Color.black))))
            } else {
                shape
                    .fill(Color.globalFill)
                    .cornerRadius(cornerRadius)
            }
        }
    }
}

import SwiftUI

// MARK: - ColorSchemeSwitch

struct ColorSchemeSwitch: View {
    @Environment(\.colorScheme) var defaultScheme
    @Binding var colorScheme: ColorScheme?
    @State private var ratio = 1.0
    @TextColor private var foreground
    @BackgroundColor private var background

    var body: some View {
        Button {
            ratio = 0.0
            toggle()
            withAnimation(.smooth(duration: 0.6)) {
                ratio = 1.0
            }
        } label: {
            ZStack {
                SwitchShape(angle: .degrees(-90), ratio: isOn ? 1 : ratio, reversed: true)
                    .foregroundStyle(background)
                    .background(foreground, in: Circle())
                    .opacity(isOn ? 1 - ratio : ratio)
                SwitchShape(angle: .degrees(90), ratio: isOn ? ratio : 1, reversed: false)
                    .foregroundStyle(foreground)
                    .background(background, in: Circle())
                    .opacity(isOn ? ratio : 1 - ratio)
            }
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .contentShape(Circle())
    }

    var isOn: Bool {
        (colorScheme ?? defaultScheme) == .light
    }

    func toggle() {
        colorScheme = isOn ? .dark : .light
    }
}

// MARK: - Animatable Shape

private struct SwitchShape: Shape, Animatable {
    var angle: Angle = .degrees(90)
    var ratio = 0.0
    var reversed: Bool = false

    var animatableData: Double {
        get { ratio }
        set { ratio = min(max(newValue, 0), 1) }
    }

    func path(in rect: CGRect) -> Path {
        let circle0 = Circle()
            .path(in: rect)
        let circle1 = Circle()
            .trim(from: 0, to: 0.5)
            .path(in: rect.scale(scale1))
        let circle2 = Circle()
            .trim(from: 0.0, to: 0.5)
            .path(in: rect.scale(scale2))
        let circle3 = Circle()
            .trim(from: 0.5, to: 1.0)
            .path(in: rect.scale(scale2))
        return circle0
            .subtracting(circle1)
            .union(circle2)
            .subtracting(circle3)
            .rotation(rotation + angle, anchor: .center)
            .path(in: rect)
    }

    var scale1: Double {
        1 - 0.1 * ((1 + cos(2 * .pi * ratio)) / 2)
    }

    var scale2: Double {
        1 - 0.5 * ((1 + cos(2 * .pi * ratio)) / 2)
    }

    var rotation: Angle {
        let sign = reversed ? -1.0 : 1.0
        return .radians(sign * (.pi / 2) * (1 - 2 * (ratio - 0.5)))
    }
}

// MARK: -

private extension ColorSchemeSwitch {
    @propertyWrapper
    struct BackgroundColor: DynamicProperty {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.colorPalette.foreground) private var foregroundColor
        @Environment(\.colorPalette.background) private var background

        var wrappedValue: Color {
            switch colorScheme {
            case .dark:
                return foregroundColor
            default:
                return background
            }
        }
    }
}

// MARK: -

private extension CGRect {
    func scale(_ scale: CGFloat) -> CGRect {
        let c0 = CGPoint(x: midX, y: midY)
        let r0 = min(width, height) / 2
        let r1 = scale * r0
        let o1 = CGPoint(x: c0.x - r1, y: c0.y - r1)
        let s1 = CGSize(width: 2 * r1, height: 2 * r1)
        return CGRect(origin: o1, size: s1)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var colorScheme = ColorScheme?.some(.light)

    ColorSchemeSwitch(colorScheme: $colorScheme)
        .padding()
        .background { Color.blue.ignoresSafeArea() }
}

import SwiftUI

// MARK: - ColorPalette

struct ColorPalette: Hashable, Identifiable {
    var id = UUID()
    var name: ColorPalette.Name
    var background: Color
    var foreground: Color
    var symbol1: Color
    var symbol2: Color

    init(name: ColorPalette.Name) {
        self.name = name
        background = Color.init("\(Self.self)/\(name.rawValue)/background", bundle: .module)
        foreground = Color("\(Self.self)/\(name.rawValue)/foreground", bundle: .module)
        symbol1 = Color("\(Self.self)/\(name.rawValue)/symbol1", bundle: .module)
        symbol2 = Color("\(Self.self)/\(name.rawValue)/symbol2", bundle: .module)
    }
}

extension ColorPalette {
    static let `default` = Self(name: ColorPalette.Name.default)

    static let allCases: [Self] = ColorPalette.Name.allCases
        .map(Self.init(name:))
}

// MARK: - ColorPalette.Name

extension ColorPalette {
    enum Name: String, Hashable, CaseIterable {
        case `default`
        case apricot
        case astra
        case brandyPunch
        case carnation
        case carouselPink
        case ceriseRed
        case contessa
        case emerald
        case froly
        case funBlue
        case fuzzyWuzzyBrown
        case gableGreen
        case hitPink
        case java
        case lima
        case lochmara
        case mauve
        case mulberry
        case ochre
        case persianGreen
        case redDamask
        case revolver
        case rodeoDust
        case roman
        case romanCoffee
        case royalPurple
        case schoolBusYellow
        case shipGrayLightShade
        case trueV
        case wattle
        case whiskey
    }
}

// MARK: - Color Palette

#Preview {
    @Previewable @State var ratio: Double = 0

    NavigationStack {
        ZStack {
            List {
                ForEach(ColorPalette.allCases) { palette in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(String(describing: palette.name))
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.leading)
                        HStack(spacing: 0) {
                            palette.symbol1
                            palette.symbol2.hueRotation(.radians(2 * .pi * ratio))
                            palette.background.hueRotation(.radians(2 * .pi * ratio))
                            palette.foreground.hueRotation(.radians(2 * .pi * ratio))
                        }
                        .frame(height: 80)
                    }
                    .padding(.top)
                }
                .listRowInsets(.init())

                Rectangle()
                    .foregroundStyle(.systemGroupedBackground)
                    .frame(height: 160)
                    .listRowInsets(.init())
                #if os(iOS) || os(macOS)
                    .listRowSeparator(.hidden, edges: .all)
                #endif
            }
            .listStyle(.automatic)

            VStack(alignment: .trailing, spacing: 0) {
                Color.clear
                RingSlider(ratio: $ratio)
                    .frame(width: 120, height: 120)
                    .padding()
                    .tint(.mint.opacity(0.6))
            }
        }
        .toolbar {
            Button(String(localized: "Reset", bundle: .module)) {
                withAnimation { ratio = ratio.rounded(.toNearestOrEven) }
            }
        }
        .navigationTitle(String(localized: "Color Palette", bundle: .module))
    }
}

private struct RingSlider: View, Animatable {
    @Binding var ratio: Double
    var animatableData: Double

    init(ratio: Binding<Double>) {
        _ratio = ratio
        animatableData = ratio.wrappedValue
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let ringRadius = min(size.width, size.height) / 2
            ZStack {
                // Ring
                let dotSize = ringRadius / 3
                let lineWidth = 0.5 * dotSize
                Circle()
                    .strokeBorder(lineWidth: lineWidth)
                    .foregroundStyle(.tint)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
                // Dot
                let r = ringRadius - lineWidth / 2
                let t = 2 * .pi * animatableData - .pi / 2
                Circle()
                    .frame(width: dotSize, height: dotSize)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .offset(x: r * cos(t), y: r * sin(t))
            }
            .gesture(
                DragGesture().onChanged { value in
                    var location = value.location
                    location.x -= ringRadius
                    location.y -= ringRadius
                    location.y *= -1
                    let t = atan2(location.x, location.y) / (2 * .pi)
                    ratio = (t + 1).remainder(dividingBy: 1)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

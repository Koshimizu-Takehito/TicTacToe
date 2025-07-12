import SwiftUI

/// Animated grid lines used as the Tic‑Tac‑Toe board background.
struct LatticeView: View {
    @State private var ratio: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Lattice(animatableData: ratio)
            .onAppear {
                let animation: Animation = reduceMotion
                    ? .easeInOut(duration: 1)
                    : .spring(duration: 1)
                withAnimation(animation) {
                    ratio = 1
                }
            }
    }
}

/// Grid shape that animates its drawing progress.
private struct Lattice: View, Animatable {
    @Environment(\.colorPalette.foreground) private var color
    @Environment(\.latticeSpacing) private var lineWidth
    var animatableData: Double
    var ratio: Double { animatableData }

    var body: some View {
        Canvas { context, size in
            let size = min(size.width, size.height)
            let length: Double = size
            [
                // left vertical line
                CGRect(
                    x: 1.0 * size / 3.0 - lineWidth / 2.0,
                    y: (1.0 - ratio) * length / 2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // right vertical line
                CGRect(
                    x: 2.0 * size / 3.0 - lineWidth / 2.0,
                    y: (1.0 - ratio) * length / 2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // top horizontal line
                CGRect(
                    x: (1.0 - ratio) * length / 2,
                    y: 1.0 * size / 3.0 - lineWidth / 2.0,
                    width: length * ratio,
                    height: lineWidth
                ),
                // bottom horizontal line
                CGRect(
                    x: (1.0 - ratio) * length / 2,
                    y: 2.0 * size / 3.0 - lineWidth / 2.0,
                    width: length * ratio,
                    height: lineWidth
                ),
            ]
            .map { Path(roundedRect: $0, cornerSize: .zero) }
            .forEach { context.fill($0, with: .color(Color(color))) }
        }
    }
}

#Preview {
    Lattice(animatableData: 1)
}

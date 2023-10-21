import SwiftUI

struct LatticeView: View {
    @State private var ratio: Double = 0

    var body: some View {
        Lattice(animatableData: ratio)
            .onAppear {
                withAnimation(.custom(duration: 1)) {
                    ratio = 1
                }
            }
    }
}

/// 格子
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
                // タテ（左）
                CGRect(
                    x: 1.0 * size/3.0 - lineWidth/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // タテ（右）
                CGRect(
                    x: 2.0 * size/3.0 - lineWidth/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // ヨコ（上）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 1.0 * size/3.0 - lineWidth/2.0,
                    width: length * ratio,
                    height: lineWidth
                ),
                // ヨコ（下）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 2.0 * size/3.0 - lineWidth/2.0,
                    width: length * ratio,
                    height: lineWidth
                )
            ]
                .map { Path(roundedRect: $0, cornerSize: .zero) }
                .forEach { context.fill($0, with: .color(Color(color))) }
        }
    }
}

#Preview {
    Lattice(animatableData: 1)
}

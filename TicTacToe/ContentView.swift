import SwiftUI

struct ContentView: View {
    @State var ratio: Double = 0

    var body: some View {
        ZStack {
            Lattice(color: .blue, ratio: ratio)
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
        }
        .padding()
        .modifier(Background(color: .orange))
        .onAppear {
            withAnimation {
                ratio = 1
            }
        }
    }
}

/// 格子
struct Lattice: View, Animatable {
    var animatableData: Double {
        get { ratio } 
        set { ratio = newValue }
    }

    var color: Color
    var ratio: Double

    var body: some View {
        Canvas { context, size in
            let c = max(size.width, size.height)
            let d = min(size.width, size.height)
            let width: Double = 6
            let length: Double = d
            let offset = (
                x: size.width > size.height ? abs(c-d)/2.0 : .zero,
                y: size.height > size.width ? abs(c-d)/2.0 : .zero
            )
            [
                // タテ（左）
                CGRect(
                    x: 1.0 * d/3.0 - width/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: width,
                    height: length * ratio
                ),
                // タテ（右）
                CGRect(
                    x: 2.0 * d/3.0 - width/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: width,
                    height: length * ratio
                ),
                // ヨコ（上）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 1.0 * d/3.0 - width/2.0,
                    width: length * ratio,
                    height: width
                ),
                // ヨコ（下）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 2.0 * d/3.0 - width/2.0, 
                    width: length * ratio,
                    height: width
                )
            ]
            .map { rect in
                var rect = rect
                rect.origin.x += offset.x
                rect.origin.y += offset.y
                return rect
            }
            .map { Path(roundedRect: $0, cornerSize: .zero) }
            .forEach { context.fill($0, with: .color(color)) }
        }
    }
}

/// 背景
struct Background: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(in: Rectangle())
            .backgroundStyle(color)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

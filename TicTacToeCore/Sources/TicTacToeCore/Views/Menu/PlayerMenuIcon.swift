import SwiftUI

/// Menu のアイコンとして設定する◯✕のアイコン
struct PlayerMenuIcon: View {
    let symbol: Symbol
    @State private var size: CGSize = .zero
    @TextColor private var color

    var body: some View {
        Group {
            switch symbol {
            case .circle:
                RingMark(ratio: 1)
            case .cross:
                CrossMark(ratio: 1)
            }
        }
        .background(content: sizeReader)
        .frame(width: size.width, height: size.height)
        .environment(\.symbolLineWidth, size.height / 10)
        .environment(\.colorPalette.symbol1, color)
        .environment(\.colorPalette.symbol2, color)
    }

    private func sizeReader() -> some View {
        Text(String(describing: symbol))
            .font(.title.bold())
            .fixedSize()
            .foregroundStyle(.clear)
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.size, initial: true) { _, size in
                            self.size = size
                        }
                }
            }
    }
}

#Preview {
    PlayerMenuIcon(symbol: .circle)
}

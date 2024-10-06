import SwiftUI
import WidgetKit

public struct RingMark: View {
    @Environment(\.colorPalette.symbol1) private var color
    let lineWidth: Double

    public init(lineWidth: Double) {
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Circle()
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
    }
}

import SwiftUI

extension View {
    /// Applies a reasonable minimum frame size for the macOS app.
    public func defaultFrame() -> some View {
        modifier(TicTacToeFrame())
    }
}

#if os(macOS)
    /// View modifier that sets a minimum frame size when running on macOS.
    public struct TicTacToeFrame: ViewModifier {
        public init() {}

        public func body(content: Content) -> some View {
            content.frame(minWidth: 360, minHeight: 0.8 * 360)
        }
    }
#else
    public typealias TicTacToeFrame = EmptyModifier
#endif

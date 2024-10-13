import SwiftUI

extension View {
    /// MacOS app 用に下限のサイズを定義を設定する
    public func defaultFrame() -> some View {
        modifier(TicTacToeFrame())
    }
}

#if os(macOS)
    /// MacOS app 用に下限のサイズを定義を設定する
    public struct TicTacToeFrame: ViewModifier {
        public init() {}

        public func body(content: Content) -> some View {
            content.frame(minWidth: 360, minHeight: 0.8 * 360)
        }
    }
#else
    public typealias TicTacToeFrame = EmptyModifier
#endif

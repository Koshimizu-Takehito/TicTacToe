import SwiftUI

// MARK: - GameBoardModifier

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
struct GameBoardPreviewModifier: PreviewModifier {
    let gameBoard: GameBoard

    func body(content: Content, context _: Void) -> some View {
        content.modifier(GameBoardModifier(gameBoard: gameBoard))
    }
}

// MARK: -

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    static var myEnvironment: PreviewTrait<T> {
        .modifier(GameBoardPreviewModifier(gameBoard: GameBoard()))
    }
}

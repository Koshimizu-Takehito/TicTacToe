import Observation
import SwiftUI

@MainActor
@Observable
final class GameBoardViewModel {
    private let gameBoard: GameBoard

    private(set) var drawId = UUID()
    private(set) var colorPalette: ColorPalette = .default
    var colorScheme: ColorScheme?
    private var role1: PlayMode { gameBoard.role1 }
    private var role2: PlayMode { gameBoard.role2 }
    private var isPlayerGame: Bool { role1 == .player || role2 == .player }

    init(gameBoard: GameBoard) {
        self.gameBoard = gameBoard
    }

    func allowsHitTesting() -> Bool {
        switch gameBoard.gameState {
        case .win, .draw:
            true
        case .ongoing:
            gameBoard.playerRole == .player
        }
    }

    func restartPlayerGame() {
        if isPlayerGame {
            reset()
        }
    }

    func restartComputerGame() {
        if !isPlayerGame {
            reset()
        }
    }

    func reset() {
        reset(color: .allCases.randomElement()!)
    }

    func reset(color: ColorPalette) {
        drawId = UUID()
        withAnimation(.spring(duration: 1)) {
            gameBoard.reset()
            colorPalette = color
        }
    }
}

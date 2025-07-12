import Observation
import SwiftUI

@MainActor
@Observable
final class GameBoardViewModel {
    let gameBoard: GameBoard

    private(set) var drawId = UUID()
    private(set) var colorPalette: ColorPalette
    var colorScheme: ColorScheme
    var reduceMotion: Bool
    private var role1: PlayMode { gameBoard.role1 }
    private var role2: PlayMode { gameBoard.role2 }
    private var isPlayerGame: Bool { role1 == .player || role2 == .player }

    init(gameBoard: GameBoard = .init(), colorPalette: ColorPalette = .default, colorScheme: ColorScheme = .light, reduceMotion: Bool = false) {
        self.gameBoard = gameBoard
        self.colorPalette = colorPalette
        self.colorScheme = colorScheme
        self.reduceMotion = reduceMotion
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
            reset(reduceMotion: reduceMotion)
        }
    }

    func restartComputerGame() {
        if !isPlayerGame {
            reset(reduceMotion: reduceMotion)
        }
    }

    func reset(reduceMotion: Bool = false) {
        reset(color: .allCases.randomElement()!, reduceMotion: reduceMotion)
    }

    func reset(color: ColorPalette, reduceMotion: Bool = false) {
        drawId = UUID()
        let animation: Animation = reduceMotion ? .easeInOut(duration: 1) : .spring(duration: 1)
        withAnimation(animation) {
            gameBoard.reset()
            colorPalette = color
        }
    }
}

extension GameBoardViewModel {
    func recieve(url: URL) {
        if let newPalette = url.colorPalette {
            update(colorPalette: newPalette)
        }
        if let newScheme = url.colorScheme {
            update(colorScheme: newScheme)
        }
    }

    private func update(colorPalette newValue: ColorPalette) {
        if colorPalette.name != newValue.name {
            colorPalette = newValue
        }
    }

    private func update(colorScheme newScheme: ColorScheme?) {
        if colorScheme != newScheme, let newScheme {
            colorScheme = newScheme
        }
    }
}

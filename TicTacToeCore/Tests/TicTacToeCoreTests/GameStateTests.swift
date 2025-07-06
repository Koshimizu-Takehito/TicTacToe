import Testing
@testable import TicTacToeCore
import Foundation

@Suite("GameState")
struct GameStateTests {
    @Test func isGameFinished() {
        #expect(!GameState.ongoing.isGameFinished)
        #expect(GameState.draw.isGameFinished)
        #expect(GameState.win(.first, positions: []).isGameFinished)
    }

    @Test func winnerAndPositions() {
        let positions: [IndexPath] = [[0,0], [1,1], [2,2]]
        let state = GameState.win(.second, positions: positions)
        let result = state.winnerAndPositions
        #expect(result.winner == .second)
        #expect(result.positions == positions)
    }
}

import Testing
@testable import TicTacToeCore
import Foundation

@Suite("GameBoardLogic")
struct GameBoardLogicTests {
    @Test func checkGameStateDetectsRowWin() {
        var board = GameBoardLogic()
        board.place(at: [0,0], player: .first)
        board.place(at: [0,1], player: .first)
        board.place(at: [0,2], player: .first)

        if case let .win(winner, positions) = board.checkGameState() {
            #expect(winner == .first)
            #expect(Set(positions) == Set([[0,0], [0,1], [0,2]]))
        } else {
            #expect(false, "Expected win")
        }
    }

    @Test func checkGameStateDraw() {
        var board = GameBoardLogic()
        let pattern: [Player] = [
            .first, .second, .first,
            .first, .second, .second,
            .second, .first, .first
        ]
        for i in 0..<9 {
            board.place(at: [i/3, i%3], player: pattern[i])
        }
        #expect(board.checkGameState() == .draw)
    }

    @Test func minMaxFindsWinningMove() {
        var board = GameBoardLogic()
        board.place(at: [0,0], player: .first)
        board.place(at: [1,1], player: .second)
        board.place(at: [0,1], player: .first)
        board.place(at: [1,0], player: .second)

        let score = board.minMax(current: .first, players: (me: .first, opponent: .second))
        #expect(score == 1)
    }
}

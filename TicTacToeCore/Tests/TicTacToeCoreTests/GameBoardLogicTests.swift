import Testing
@testable import TicTacToeCore
import Foundation

/// Unit tests for ``GameBoardLogic``.
/// ゲーム盤ロジックの単体テストです。
///
/// Each test verifies a particular aspect of the game board logic such as
/// win detection or the min/max algorithm. The goal of these tests is to
/// ensure that the core game mechanics behave as expected without needing the
/// UI or other layers of the app.
/// 各テストでは勝利判定やミニマックスアルゴリズムなど、
/// ゲーム盤の核となる動作が正しく機能するかを検証します。

@Suite("GameBoardLogic")
struct GameBoardLogicTests {
    /// Verifies that a horizontal three-in-a-row is detected as a win.
    /// 横一列が揃うと勝利と判定されることを確認する。
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

    /// Ensures the game is reported as a draw when the board is full without a winner.
    /// 盤面が埋まり勝者がいない場合に引き分けとなることを確認する。
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

    /// Confirms that the ``GameBoardLogic`` min/max implementation finds a winning move.
    /// ``GameBoardLogic`` のミニマックス実装が勝利手を導くことをテストする。
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

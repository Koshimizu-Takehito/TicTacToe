import Testing
@testable import TicTacToeCore
import Foundation

/// Tests for ``GameState`` helpers.
/// ``GameState`` に関するヘルパーのテストです。
///
/// ``GameState`` encapsulates the current outcome of a game and provides
/// convenience properties to query common information. These tests validate
/// those computed properties.
/// ``GameState`` はゲームの現在の結果を保持し、よく使う情報を取得する
/// プロパティを提供します。ここではそれらの計算プロパティを検証します。

@Suite("GameState")
struct GameStateTests {
    /// Checks the ``GameState.isGameFinished`` convenience property.
    /// ``GameState.isGameFinished`` プロパティが正しく判定するかを確認する。
    @Test func isGameFinished() {
        #expect(!GameState.ongoing.isGameFinished)
        #expect(GameState.draw.isGameFinished)
        #expect(GameState.win(.first, positions: []).isGameFinished)
    }

    /// Ensures ``GameState.winnerAndPositions`` returns the associated values from the ``.win`` case.
    /// ``.win`` ケースに紐付く勝者と座標が取得できることをテストする。
    @Test func winnerAndPositions() {
        let positions: [IndexPath] = [[0,0], [1,1], [2,2]]
        let state = GameState.win(.second, positions: positions)
        let result = state.winnerAndPositions
        #expect(result.winner == .second)
        #expect(result.positions == positions)
    }
}

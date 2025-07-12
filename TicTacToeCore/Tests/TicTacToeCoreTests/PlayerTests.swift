import Testing
@testable import TicTacToeCore

/// Unit tests for ``Player`` convenience API.
/// ``Player`` のユーティリティ API に対する単体テストです。
///
/// ``Player`` represents each participant in the game. These tests ensure
/// simple helper methods on ``Player`` behave as expected.
/// ``Player`` 型が持つ簡単なヘルパーメソッドの動作を検証します。

@Suite("Player")
struct PlayerTests {
    /// Verifies ``Player.opposite`` returns the other player.
    /// ``Player.opposite`` が常に相手プレイヤーを返すことを確認する。
    @Test func opposite() {
        #expect(Player.first.opposite == .second)
        #expect(Player.second.opposite == .first)
    }

    /// Tests mutating ``Player.toggle()`` swaps between `.first` and `.second`.
    /// ``Player.toggle()`` メソッドでプレイヤーが交代することをテストする。
    @Test func toggle() {
        var player: Player = .first
        player.toggle()
        #expect(player == .second)
        player.toggle()
        #expect(player == .first)
    }
}

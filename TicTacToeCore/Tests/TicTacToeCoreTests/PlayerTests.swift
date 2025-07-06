import Testing
@testable import TicTacToeCore

@Suite("Player")
struct PlayerTests {
    @Test func opposite() {
        #expect(Player.first.opposite == .second)
        #expect(Player.second.opposite == .first)
    }

    @Test func toggle() {
        var player: Player = .first
        player.toggle()
        #expect(player == .second)
        player.toggle()
        #expect(player == .first)
    }
}

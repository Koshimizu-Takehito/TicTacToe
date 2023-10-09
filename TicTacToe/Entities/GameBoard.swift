import Foundation

private let checkPositions: [[IndexPath]] = [
    // タテ
    [[0, 0], [1, 0], [2, 0]],
    [[0, 1], [1, 1], [2, 1]],
    [[0, 2], [1, 2], [2, 2]],
    // ヨコ
    [[0, 0], [0, 1], [0, 2]],
    [[1, 0], [1, 1], [1, 2]],
    [[2, 0], [2, 1], [2, 2]],
    // ナナメ
    [[0, 0], [1, 1], [2, 2]],
    [[0, 2], [1, 1], [2, 0]]
]

struct GameBoard {
    var symbols: [IndexPath: SymbolType] = [:]

    mutating func place(at index: IndexPath, player: Player) {
        symbols[index] = player == .player1 ? .circle : .cross
    }

    func minMax(current: Player, players: (me: Player, opponent: Player)) -> Int {
        switch checkGameState() {
        case .win(players.me, _):
            return 1
        case .win(players.opponent, _):
            return -1
        case .draw:
            return 0
        default:
            break
        }
        var bestScore: Int = (current == players.opponent) ? .max : .min
        for x in (0..<3).shuffled() {
            for y in (0..<3).shuffled() {
                if symbols[[x, y]] == nil {
                    var copy = self
                    copy.place(at: [x, y], player: current)
                    let score = copy.minMax(current: current.opposite, players: players)
                    bestScore = (current == players.me) ? max(score, bestScore) : min(score, bestScore)
                }
            }
        }
        return bestScore
    }

    func checkGameState() -> GameState {
        for positions in checkPositions {
            if let (winner, positions) = checkWinnerAndPositions(positions) {
                return .win(winner, positions: positions)
            }
        }
        return symbols.count < 9 ? .ongoing : .draw
    }

    private func checkWinnerAndPositions(_ mm: [IndexPath]) -> (winner: Player, positions: [IndexPath])? {
        if symbols[mm[0]] == symbols[mm[1]], symbols[mm[1]] == symbols[mm[2]] {
            switch symbols[mm[0]] {
            case .circle:
                return (.player1, mm)
            case .cross:
                return (.player2, mm)
            case .none:
                return nil
            }
        }
        return nil
    }
}

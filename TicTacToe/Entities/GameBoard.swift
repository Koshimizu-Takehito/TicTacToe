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
    var marks: [IndexPath: MarkType] = [:]

    mutating func place(at index: IndexPath, player: Player) {
        marks[index] = player == .player1 ? .circle : .cross
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
                if marks[[x, y]] == nil {
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
        return marks.count < 9 ? .ongoing : .draw
    }

    private func checkWinnerAndPositions(_ mm: [IndexPath]) -> (winner: Player, positions: [IndexPath])? {
        if marks[mm[0]] == marks[mm[1]], marks[mm[1]] == marks[mm[2]] {
            switch marks[mm[0]] {
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

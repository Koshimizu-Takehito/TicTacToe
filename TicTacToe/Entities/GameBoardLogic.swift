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

struct GameBoardLogic {
    /// 取った陣地
    var occupied: [IndexPath: Player] = [:]

    mutating func place(at index: IndexPath, player: Player) {
        occupied[index] = player
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
                if occupied[[x, y]] == nil {
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
        return occupied.count < 9 ? .ongoing : .draw
    }

    private func checkWinnerAndPositions(_ mm: [IndexPath]) -> (winner: Player, positions: [IndexPath])? {
        if occupied[mm[0]] == occupied[mm[1]], occupied[mm[1]] == occupied[mm[2]] {
            switch occupied[mm[0]] {
            case let winner?:
                return (winner, mm)
            case .none:
                return nil
            }
        }
        return nil
    }
}

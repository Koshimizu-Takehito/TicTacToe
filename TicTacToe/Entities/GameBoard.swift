import Foundation

struct GameBoard {
    var marks: [IndexPath: MarkType] = [:]

    mutating func place(at index: IndexPath, player: Player) {
        marks[index] = player == .player1 ? .circle : .cross
    }

    func checkWinner() -> GameState {
        func winner(_ m0: MarkType?, _ m1: MarkType?, _ m2: MarkType?) -> Player? {
            if m0 == m1, m1 == m2 {
                switch m0 {
                case .circle:
                    return .player1
                case .cross:
                    return .player2
                case .none:
                    return nil
                }
            }
            return nil
        }

        for i in 0...2 {
            if let winner = winner(marks[[0, i]], marks[[1, i]], marks[[2, i]]) {
                return .win(winner)
            }
            if let winner = winner(marks[[i, 0]], marks[[i, 1]], marks[[i, 2]]) {
                return .win(winner)
            }
        }
        if let winner = winner(marks[[0, 0]], marks[[1, 1]], marks[[2, 2]]) {
            return .win(winner)
        }
        if let winner = winner(marks[[0, 2]], marks[[1, 1]], marks[[2, 0]]) {
            return .win(winner)
        }
        return marks.count < 9 ? .ongoing : .draw
    }

    func minimax(player: Player) -> Int {
        switch checkWinner() {
        case .win(.player2):
            return 1
        case .win(.player1):
            return -1
        case .draw:
            return 0
        default:
            break
        }

        var bestScore: Int = (player == .player1) ? .max : .min
        for x in 0..<3 {
            for y in 0..<3 {
                if marks[[x, y]] == nil {
                    var copy = self
                    copy.place(at: [x, y], player: player)
                    let score = copy.minimax(player: player.opposite)
                    bestScore = player == .player2 ? max(score, bestScore) : min(score, bestScore)
                }
            }
        }
        return bestScore
    }
}

import Foundation

/// Internal logic for evaluating the state of the Tic‑Tac‑Toe board.
///
/// This structure tracks which player has occupied which squares and
/// provides routines for placing pieces, checking for wins, and running
/// a simple Min‑Max AI search.

/// Board coordinates that represent every line to check for a win.
private let checkPositions: [[IndexPath]] = [
    // vertical lines
    [[0, 0], [1, 0], [2, 0]],
    [[0, 1], [1, 1], [2, 1]],
    [[0, 2], [1, 2], [2, 2]],
    // horizontal lines
    [[0, 0], [0, 1], [0, 2]],
    [[1, 0], [1, 1], [1, 2]],
    [[2, 0], [2, 1], [2, 2]],
    // diagonals
    [[0, 0], [1, 1], [2, 2]],
    [[0, 2], [1, 1], [2, 0]],
]

struct GameBoardLogic {
    /// The current pieces placed on the board.
    ///
    /// Keys are board coordinates expressed as `IndexPath` where
    /// the first index is the row and the second is the column.
    /// Values indicate which player occupies that square.
    var occupied: [IndexPath: Player] = [:]

    /// Places a piece for a player at the specified board location.
    /// - Parameters:
    ///   - index: The row and column to place the piece.
    ///   - player: The player making the move.
    mutating func place(at index: IndexPath, player: Player) {
        occupied[index] = player
    }

    /// Evaluates the board using the Min‑Max algorithm.
    ///
    /// - Parameters:
    ///   - current: The player currently making a decision.
    ///   - players: Tuple containing the player we are optimizing for and the opponent.
    /// - Returns: Score representing the desirability of the board state.
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
        for x in (0 ..< 3).shuffled() {
            for y in (0 ..< 3).shuffled() {
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

    /// Determines the current game state by checking all winning lines.
    func checkGameState() -> GameState {
        for positions in checkPositions {
            if let (winner, positions) = checkWinnerAndPositions(positions) {
                return .win(winner, positions: positions)
            }
        }
        return occupied.count < 9 ? .ongoing : .draw
    }

    /// Checks whether the supplied positions contain the same player's pieces.
    /// - Parameter mm: A list of three board coordinates.
    /// - Returns: The winning player and the winning line if found.
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

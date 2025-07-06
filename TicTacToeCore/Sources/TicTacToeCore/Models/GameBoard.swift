import Observation
import SwiftUI

/// Manages a single game of Tic‑Tac‑Toe, coordinating the board logic,
/// active players and their assigned symbols.

/// Stores which symbol each player uses.
struct PlayerSymbolSetting {
    /// Mapping of player to their chosen symbol.
    var symbols: [Player: Symbol] = [
        .first: .default,
        .second: .default.opposite,
    ]

    /// Convenience helper to access a player's symbol.
    func symbol(for player: Player) -> Symbol {
        self[player]
    }

    /// Accessor for player symbols using subscript syntax.
    subscript(_ player: Player) -> Symbol {
        get { symbols[player]! }
        set { symbols[player] = newValue }
    }
}

@Observable
@MainActor
@dynamicMemberLookup
/// Observable model object that controls game progression and AI moves.
final class GameBoard {
    private var gameBoard = GameBoardLogic()
    /// Symbols assigned to each player.
    var symbols = PlayerSymbolSetting()

    /// The play mode for the first player.
    /// When changed while it is that player's turn, a move is triggered automatically.
    var role1: PlayMode = .player {
        didSet {
            if currentPlayer == .first {
                place()
            }
        }
    }

    /// The play mode for the second player.
    /// When changed while it is that player's turn, a move is triggered automatically.
    var role2: PlayMode = .computer(.medium) {
        didSet {
            if currentPlayer == .second {
                place()
            }
        }
    }

    /// Current state of the game.
    private(set) var gameState: GameState = .ongoing

    /// Returns the role of the player whose turn it currently is.
    var playerRole: PlayMode {
        switch currentPlayer {
        case .first:
            role1
        case .second:
            role2
        }
    }

    /// Tracks which player's turn it is.
    private var currentPlayer: Player = .first {
        didSet { place() }
    }

    /// Returns the symbol currently placed at a given location.
    func symbol(at indexPath: IndexPath) -> Symbol? {
        gameBoard.occupied[indexPath].map(symbols.symbol(for:))
    }

    /// Returns the symbol assigned to the specified player.
    func symbol(for player: Player) -> Symbol? {
        symbols.symbol(for: player)
    }

    /// Clears the board and starts a new game.
    func reset() {
        gameBoard.occupied = [:]
        gameState = .ongoing
        currentPlayer = .first
    }

    /// Places the current player's piece at the given location if allowed
    /// and updates the game state asynchronously.
    func place(at index: IndexPath) {
        guard gameBoard.checkGameState() == .ongoing, gameBoard.occupied[index] == .none else { return }
        // place piece
        gameBoard.occupied[index] = currentPlayer

        Task.detached { [gameBoard] in
            let gameState = gameBoard.checkGameState()
            Task { @MainActor [self] in
                // update game state on the main actor
                self.gameState = gameState
                if gameState == .ongoing {
                    self.currentPlayer.toggle()
                }
            }
        }
    }

    subscript<V>(dynamicMember keyPath: WritableKeyPath<GameBoardLogic, V>) -> V {
        get { gameBoard[keyPath: keyPath] }
        set { gameBoard[keyPath: keyPath] = newValue }
    }
}

private extension GameBoard {
    /// Executes a move for the current player based on their selected play mode.
    func place() {
        Task.detached { [self] in
            switch await playerRole {
            case .player:
                break
            case .random:
                try await placeAtRandom()
            case .computer(.easy):
                try await placeByEasyAI()
            case .computer(.medium):
                try await placeByMediumAI()
            case .computer(.hard):
                try await placeByHardAI()
            }
        }
    }

    /// Places a piece at a random open location.
    func placeAtRandom() async throws {
        let gameBoard = gameBoard
        try await waitUntilCalculation {
            while gameBoard.checkGameState() == .ongoing {
                let randomPath = IndexPath.randomElement()
                if gameBoard.occupied[randomPath] == nil {
                    return randomPath
                }
            }
            return nil
        }
    }

    /// Places a piece using a basic Min‑Max search that favors slower moves.
    func placeByEasyAI() async throws {
        let gameBoard = gameBoard
        let currentPlayer = currentPlayer
        try await waitUntilCalculation {
            guard gameBoard.checkGameState() == .ongoing else {
                return nil
            }
            // For the first move just pick a random square
            guard !gameBoard.occupied.isEmpty else {
                return .randomElement()
            }
            // Use the Min‑Max algorithm to find the worst position
            let players = (me: currentPlayer, opponent: currentPlayer.opposite)
            var worstPlace = IndexPath?.none
            var worstScore = Int.max
            for i in (0 ..< 3).shuffled() {
                for j in (0 ..< 3).shuffled() {
                    let indexPath: IndexPath = [i, j]
                    guard gameBoard.occupied[indexPath] == nil else { continue }
                    var copy = gameBoard
                    copy.place(at: indexPath, player: players.me)
                    let score = copy.minMax(current: players.opponent, players: players)
                    if score < worstScore {
                        worstScore = score
                        worstPlace = indexPath
                    }
                }
            }
            return worstPlace
        }
    }

    /// Medium difficulty mixes random, easy and hard strategies.
    func placeByMediumAI() async throws {
        let p = 10 * max(10 - gameBoard.occupied.count, 0)
        if Int.random(in: 0 ..< 100) < p {
            try await placeByHardAI()
        } else if Bool.random() {
            try await placeAtRandom()
        } else {
            try await placeByEasyAI()
        }
    }

    /// Places a piece using the Min‑Max algorithm.
    func placeByHardAI() async throws {
        let gameBoard = gameBoard
        let currentPlayer = currentPlayer
        try await waitUntilCalculation {
            guard gameBoard.checkGameState() == .ongoing else {
                return nil
            }
            // For the first move just pick a random square
            guard !gameBoard.occupied.isEmpty else {
                return .randomElement()
            }
            // Use the Min‑Max algorithm to find the best position
            let players = (me: currentPlayer, opponent: currentPlayer.opposite)
            var bestPlace = IndexPath?.none
            var bestScore = Int.min
            for i in (0 ..< 3).shuffled() {
                for j in (0 ..< 3).shuffled() {
                    let indexPath: IndexPath = [i, j]
                    guard gameBoard.occupied[indexPath] == nil else { continue }
                    var copy = gameBoard
                    copy.place(at: indexPath, player: players.me)
                    let score = copy.minMax(current: players.opponent, players: players)
                    if score > bestScore {
                        bestScore = score
                        bestPlace = indexPath
                    }
                }
            }
            return bestPlace
        }
    }

    /// Runs a calculation off the main actor and places a piece when the result is ready.
    /// - Parameters:
    ///   - minWaitingTime: Minimum duration (in nanoseconds) to wait before placing the piece.
    ///   - calculation: Closure that returns the selected move.
    func waitUntilCalculation(minWaitingTime: Int64 = 660_000_000, calculation: @Sendable @escaping () -> IndexPath?) async throws {
        let beforeStates = gameBoard.occupied
        let startTime = Date.now
        Task.detached {
            if let location = calculation() {
                let elapsedTime = Int64(-startTime.timeIntervalSinceNow * 1_000_000_000)
                try await Task.sleep(nanoseconds: UInt64(max(minWaitingTime - elapsedTime, 0)))
                Task { @MainActor in
                    let gameBoard = self.gameBoard
                    guard gameBoard.occupied == beforeStates else { return }
                    self.place(at: location)
                }
            }
        }
    }
}

private extension IndexPath {
    static func randomElement(row: Range<Int> = 0 ..< 3, column: Range<Int> = 0 ..< 3) -> IndexPath {
        [row.randomElement() ?? 0, column.randomElement() ?? 0]
    }
}

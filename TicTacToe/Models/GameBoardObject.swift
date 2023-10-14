import SwiftUI
import Observation

@Observable
@dynamicMemberLookup
final class GameBoardObject {
    private var gameBoard = GameBoard()

    var role1: PlayerMode = .player {
        didSet {
            if currentPlayer == .player1 {
                place()
            }
        }
    }
    var role2: PlayerMode = .computer {
        didSet {
            if currentPlayer == .player2 {
                place()
            }
        }
    }

    private(set) var gameState: GameState = .ongoing

    private var playerRole: PlayerMode {
        switch currentPlayer {
        case .player1:
            role1
        case .player2:
            role2
        }
    }

    private var currentPlayer: Player = .player1 {
        didSet { place() }
    }

    func allowsHitTesting() -> Bool {
        switch gameBoard.checkGameState() {
        case .win, .draw:
            return true
        case .ongoing:
            return playerRole == .player
        }
    }

    func reset() {
        gameBoard.symbols = [:]
        gameState = .ongoing
        currentPlayer = .player1
    }

    func place(at index: IndexPath) -> Void {
        guard gameBoard.checkGameState() == .ongoing && gameBoard.symbols[index] == .none else { return }
        // 配置
        gameBoard.symbols[index] = currentPlayer.symbol

        Task.detached { [gameBoard] in
            let gameState = gameBoard.checkGameState()
            Task { @MainActor [self] in
                // 状態の更新
                self.gameState = gameState
                if gameState == .ongoing {
                    self.currentPlayer.toggle()
                }
            }
        }
    }

    subscript<V>(dynamicMember keyPath: WritableKeyPath<GameBoard, V>) -> V {
        get { gameBoard[keyPath: keyPath] }
        set { gameBoard[keyPath: keyPath] = newValue }
    }
}

private extension GameBoardObject {
    func place() {
        Task.detached { [self] in
            switch playerRole {
            case .player:
                break
            case .random:
                try await placeAtRandom()
            case .computer:
                try await placeByAI()
            }
        }
    }

    /// ランダムな位置に配置する
    func placeAtRandom() async throws {
        try await waitUntilCalculation { [self] () -> IndexPath? in
            while gameBoard.checkGameState() == .ongoing {
                let randomPath = IndexPath.randomElement()
                if gameBoard.symbols[randomPath] == nil {
                    return randomPath
                }
            }
            return nil
        }
    }

    /// アルゴリズムによって配置する
    func placeByAI() async throws {
        try await waitUntilCalculation { [self] () -> IndexPath? in
            guard gameBoard.checkGameState() == .ongoing else {
                return nil
            }
            // 初期配置はどこでも良いのでランダムに配置する
            guard !gameBoard.symbols.isEmpty else {
                return .randomElement()
            }
            // Min-Max
            let players = (me: currentPlayer, opponent: currentPlayer.opposite)
            var bestPlace = IndexPath?.none
            var bestScore = Int.min
            for i in (0..<3).shuffled() {
                for j in (0..<3).shuffled() {
                    let indexPath: IndexPath = [i, j]
                    guard gameBoard.symbols[indexPath] == nil else { continue }
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

    func waitUntilCalculation(minWaitingTime: Int64 = 660_000_000, calculation: @escaping () -> IndexPath?) async throws {
        let beforeStates = gameBoard.symbols
        let startTime = Date.now
        Task.detached {
            if let location = calculation() {
                let elapsedTime = Int64(-startTime.timeIntervalSinceNow * 1_000_000_000)
                try await Task.sleep(nanoseconds: UInt64(max(minWaitingTime - elapsedTime, 0)))
                Task { @MainActor [self] in
                    let gameBoard = self.gameBoard
                    guard gameBoard.symbols == beforeStates else { return }
                    self.place(at: location)
                }
            }
        }
    }
}

private extension IndexPath {
    static func randomElement(row: Range<Int> = 0..<3, column: Range<Int> = 0..<3) -> IndexPath {
        [row.randomElement() ?? 0, column.randomElement() ?? 0]
    }
}

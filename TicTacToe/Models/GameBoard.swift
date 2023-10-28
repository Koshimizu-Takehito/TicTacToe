import SwiftUI
import Observation

@Observable
@dynamicMemberLookup
final class GameBoard {
    private var gameBoard = GameBoardLogic()
    var symbols = PlayerSymbolSetting()

    var role1: PlayMode = .player {
        didSet {
            if currentPlayer == .first {
                place()
            }
        }
    }
    var role2: PlayMode = .computer(.medium) {
        didSet {
            if currentPlayer == .second {
                place()
            }
        }
    }

    private(set) var gameState: GameState = .ongoing

    private var playerRole: PlayMode {
        switch currentPlayer {
        case .first:
            role1
        case .second:
            role2
        }
    }

    private var currentPlayer: Player = .first {
        didSet { place() }
    }

    func symbol(at indexPath: IndexPath) -> Symbol? {
        gameBoard.occupied[indexPath].map(symbols.symbol(for:))
    }

    func symbol(for player: Player) -> Symbol? {
        symbols.symbol(for: player)
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
        gameBoard.occupied = [:]
        gameState = .ongoing
        currentPlayer = .first
    }

    func place(at index: IndexPath) -> Void {
        guard gameBoard.checkGameState() == .ongoing && gameBoard.occupied[index] == .none else { return }
        // 配置
        gameBoard.occupied[index] = currentPlayer

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

    subscript<V>(dynamicMember keyPath: WritableKeyPath<GameBoardLogic, V>) -> V {
        get { gameBoard[keyPath: keyPath] }
        set { gameBoard[keyPath: keyPath] = newValue }
    }
}

private extension GameBoard {
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
                if gameBoard.occupied[randomPath] == nil {
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
            guard !gameBoard.occupied.isEmpty else {
                return .randomElement()
            }
            // Min-Max
            let players = (me: currentPlayer, opponent: currentPlayer.opposite)
            var bestPlace = IndexPath?.none
            var bestScore = Int.min
            for i in (0..<3).shuffled() {
                for j in (0..<3).shuffled() {
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

    func waitUntilCalculation(minWaitingTime: Int64 = 660_000_000, calculation: @escaping () -> IndexPath?) async throws {
        let beforeStates = gameBoard.occupied
        let startTime = Date.now
        Task.detached {
            if let location = calculation() {
                let elapsedTime = Int64(-startTime.timeIntervalSinceNow * 1_000_000_000)
                try await Task.sleep(nanoseconds: UInt64(max(minWaitingTime - elapsedTime, 0)))
                Task { @MainActor [self] in
                    let gameBoard = self.gameBoard
                    guard gameBoard.occupied == beforeStates else { return }
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

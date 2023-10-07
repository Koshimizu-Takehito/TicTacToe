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

    func canPlay() -> Bool {
        playerRole == .player && gameBoard.checkGameState() == .ongoing
    }

    func reset() {
        gameBoard.marks = [:]
        currentPlayer = .player1
    }

    func place(at index: IndexPath) -> Void {
        guard gameBoard.marks[index] == .none else { return }
        // 配置
        gameBoard.marks[index] = currentPlayer.check

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
        while gameBoard.checkGameState() == .ongoing {
            func random() -> Int { (0...2).randomElement()! }
            let random: IndexPath = [random(), random()]
            if gameBoard.marks[random] == nil {
                try await Task.sleep(nanoseconds: 550_000_000)
                place(at: random)
                return
            }
        }
    }

    /// アルゴリズムによって配置する
    func placeByAI() async throws {
        // 初期配置はどこでも良いのでランダムに配置する
        if gameBoard.marks.isEmpty {
            try await Task.sleep(nanoseconds: 550_000_000)
            place(at: [(0..<3).randomElement()!, (0..<3).randomElement()!])
            return
        }

        // Min-Max
        guard gameBoard.checkGameState() == .ongoing else {
            return
        }
        let startTime = Date.now
        let players = (
            me: currentPlayer,
            opponent: currentPlayer == .player1 ? Player.player2 : .player1
        )
        var bestPlace = IndexPath?.none
        var bestScore = Int.min
        for i in (0..<3).shuffled() {
            for j in (0..<3).shuffled() {
                let indexPath: IndexPath = [i, j]
                guard gameBoard.marks[indexPath] == nil else { continue }
                var copy = gameBoard
                copy.place(at: indexPath, player: players.me)
                let score = copy.minMax(current: players.opponent, players: players)
                if score > bestScore {
                    bestScore = score
                    bestPlace = indexPath
                }
            }
        }
        if let bestPlace {
            let elapsedTime = Int64(-startTime.timeIntervalSinceNow * 1_000_000_000)
            try await Task.sleep(nanoseconds: UInt64(max(550_000_000 - elapsedTime, 0)))
            place(at: bestPlace)
        }
    }
}

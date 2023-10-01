import SwiftUI

@Observable
@dynamicMemberLookup
final class GameBoardObject {
    private var gameBoard = GameBoard()

    var role1: PlayerMode = .player {
        didSet {
            if player == .player1 {
                place()
            }
        }
    }
    var role2: PlayerMode = .computer {
        didSet {
            if player == .player2 {
                place()
            }
        }
    }

    var playerRole: PlayerMode {
        switch player {
        case .player1:
            role1
        case .player2:
            role2
        }
    }

    var player: Player = .player1 {
        didSet { place() }
    }

    func reset() {
        gameBoard.marks = [:]
        player = .player1
    }

    func place(at index: IndexPath) -> Void {
        guard gameBoard.marks[index] == .none else { return }
        gameBoard.marks[index] = player.check
        player.toggle()
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
        while gameBoard.marks.count < 9 {
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
        guard gameBoard.marks.count < 9 else { return }
        let startTime = Date.now
        var bestScore = Int.min
        var bestPlace = IndexPath?.none
        for i in 0...2 {
            for j in 0...2 {
                let indexPath: IndexPath = [i, j]
                guard gameBoard.marks[indexPath] == nil else { continue }
                var copy = gameBoard
                copy.place(at: indexPath, player: .player2)
                let score = copy.minimax(player: .player1)
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

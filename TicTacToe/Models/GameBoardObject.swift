import SwiftUI

@Observable
final class GameBoardObject {
    var gameBoard = GameBoard()

    var player: Player = .player1 {
        didSet {
            switch player {
            case .player1:
                break
            case .player2:
                Task.detached { [self] in
                    try await placeByAI()
                }
            }
        }
    }

    func place(at index: IndexPath) -> Void {
        guard gameBoard.marks[index] == .none else { return }
        gameBoard.marks[index] = player.check
        player.toggle()
    }
}

extension GameBoardObject {
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
}

extension GameBoardObject {
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

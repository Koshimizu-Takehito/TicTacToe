//
//  GameBoardView.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/10/01.
//

import SwiftUI

enum GameState {
    case ongoing
    case draw
    case win(Player)
}

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

@Observable final class GameBoardObject {
    var gameBoard = GameBoard()
    var player: Player = .player1 {
        didSet {
            switch player {
            case .player1:
                break
            case .player2:
                Task.detached { [self] in
                    try await placeAtRandom()
                }
            }
        }
    }

    func place(at index: IndexPath) -> Void {
        guard gameBoard.marks[index] == .none else { return }
        gameBoard.marks[index] = player.check
        player.toggle()
    }

    /// ランダムな位置に配置する
    func placeAtRandom() async throws {
        guard gameBoard.marks.count < 9 else { return }
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
            try await Task.sleep(nanoseconds: 550_000_000)
            place(at: bestPlace)
        }
    }
}

struct GameBoardView: View {
    @State private var ratio: Double = 0
    @State private var gameBoard = GameBoardObject()

    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    ZStack(alignment: .center) {
                        Group {
                            Lattice(ratio: ratio)
                            Tiles(marks: $gameBoard.gameBoard.marks, onTap: gameBoard.place)
                                .allowsHitTesting(gameBoard.player == .player1)
                        }
                        .frame(width: size, height: size)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environment(\.latticeSpacing, size/40)
                    .environment(\.markLineWidth, size/40)
                }
                Button(action: reset, label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                })
                .buttonStyle(TitleButtonStyle(color: .foreground))
            }
        }
        .padding()
        .modifier(Background())
        .onAppear(perform: reset)
    }

    func reset() {
        ratio = 0
        gameBoard.player = .player1
        withAnimation(.custom(duration: 1)) {
            ratio = 1
            gameBoard.gameBoard.marks = [:]
        }
    }
}

#Preview {
    GameBoardView()
}

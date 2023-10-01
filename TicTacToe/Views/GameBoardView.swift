//
//  GameBoardView.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/10/01.
//

import SwiftUI

@Observable final class GameBoardObject {
    var marks: [IndexPath: MarkType] = [:]
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
        guard marks[index] == .none else { return }
        marks[index] = player.check
        player.toggle()
    }

    /// ランダムな位置に配置する
    func placeAtRandom() async throws {
        guard marks.count < 9 else { return }

        while true {
            func random() -> Int { (0...2).randomElement()! }
            let random: IndexPath = [random(), random()]
            if marks[random] == nil {
                try await Task.sleep(nanoseconds: 550_000_000)
                place(at: random)
                return
            }
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
                            Tiles(marks: $gameBoard.marks, onTap: gameBoard.place)
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
            gameBoard.marks = [:]
        }
    }
}

#Preview {
    GameBoardView()
}

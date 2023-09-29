//
//  Tiles.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/30.
//

import SwiftUI

/// タイル領域
struct Tiles: View {
    @Binding var marks: [IndexPath: MarkType]
    @Environment(\.latticeSpacing) var spacing
    var onTap: (IndexPath) -> Void = { _ in }

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        let indexPath: IndexPath = [i, j]
                        MarkView(mark: $marks[indexPath])
                            .onTapGesture { onTap(indexPath) }
                    }
                }
            }
        }
    }
}

struct MarkView: View {
    @Binding var mark: MarkType?
    @State var ratio: Double = 0

    var body: some View {
        ZStack {
            Color.white
                .opacity(1/0xFFFF)
            Group {
                switch mark {
                case .circle:
                    RingMark(ratio: ratio)
                case .cross:
                    CrossMark(ratio: ratio)
                case .none:
                    Color.clear
                }
            }
        }
        .onChange(of: mark) { oldValue, newValue in
            ratio = 0
            withAnimation(.custom()) {
                ratio = 1
            }
        }
    }
}

#Preview {
    Tiles(marks: .constant([
        [0, 0]: .circle, [0, 1]: .circle, [0, 2]: .circle,
        [1, 0]: .circle, [1, 1]: .circle, [1, 2]: .circle,
        [2, 0]: .circle, [2, 1]: .circle, [2, 2]: .circle,
    ]))
}

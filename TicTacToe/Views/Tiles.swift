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
    @State var ratio: Double = 0
    @Binding var mark: MarkType?

    var body: some View {
        ZStack {
            Color.white
                .opacity(1/0xFFFF)
            switch mark {
            case .circle:
                RingMark(ratio: ratio)
            case .cross:
                CrossMark(ratio: ratio)
            case .none:
                Color.clear
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

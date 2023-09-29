//
//  Lattice.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

import SwiftUI

/// 格子
struct Lattice: View, Animatable {
    @Environment(\.foreground) private var color
    @Environment(\.latticeSpacing) private var lineWidth
    var ratio: Double
    var animatableData: Double {
        get { ratio }
        set { ratio = newValue }
    }

    var body: some View {
        Canvas { context, size in
            let size = min(size.width, size.height)
            let length: Double = size
            [
                // タテ（左）
                CGRect(
                    x: 1.0 * size/3.0 - lineWidth/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // タテ（右）
                CGRect(
                    x: 2.0 * size/3.0 - lineWidth/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // ヨコ（上）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 1.0 * size/3.0 - lineWidth/2.0,
                    width: length * ratio,
                    height: lineWidth
                ),
                // ヨコ（下）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 2.0 * size/3.0 - lineWidth/2.0,
                    width: length * ratio,
                    height: lineWidth
                )
            ]
                .map { Path(roundedRect: $0, cornerSize: .zero) }
                .forEach { context.fill($0, with: .color(color)) }
        }
    }
}

#Preview {
    AnimationHelper(start: 0, end: 1) { parameter in
        Lattice(ratio: parameter)
    }
}

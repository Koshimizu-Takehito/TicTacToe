//
//  Background.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

import SwiftUI

/// 背景
struct Background: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(in: Rectangle())
            .backgroundStyle(color)
            .ignoresSafeArea()
    }
}
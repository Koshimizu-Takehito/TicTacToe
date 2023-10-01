//
//  TitleButtonStyle.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

import SwiftUI

struct TitleButtonStyle: ButtonStyle {
    var color: Color = .foreground

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
            .padding()
    }
}

struct ActionButtonStyle: ButtonStyle {
    var color: Color = .foreground

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
            .padding()
    }
}

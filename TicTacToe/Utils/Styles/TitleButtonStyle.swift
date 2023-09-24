//
//  TitleButtonStyle.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

import SwiftUI

struct TitleButtonStyle: ButtonStyle {
    var color: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title.bold())
            .foregroundStyle(color)
            .frame(minHeight: 44)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

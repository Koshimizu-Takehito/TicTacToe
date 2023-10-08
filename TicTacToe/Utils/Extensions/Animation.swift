//
//  Animation.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

import SwiftUI

extension Animation {
    static func custom(duration: Double = 0.7) -> Animation {
        .spring(duration: duration)
    }
}

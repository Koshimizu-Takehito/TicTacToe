import SwiftUI

extension Animation {
    static func custom(duration: Double = 0.7) -> Animation {
        .spring(duration: duration)
    }
}

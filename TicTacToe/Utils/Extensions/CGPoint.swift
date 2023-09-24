import Foundation
import CoreGraphics

extension CGPoint {
    init(radius: Double, theta: Double) {
        self.init(x: radius * cos(theta), y: radius * sin(theta))
    }

    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        return self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        return self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *(_ lhs: Double, _ rhs: Self) -> Self {
        return self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }
}

import CoreGraphics

extension CGPoint {
    init(radius: Double, radian: Double) {
        self.init(x: radius * cos(radian), y: radius * sin(radian))
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        return self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        return self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (_ lhs: Double, _ rhs: Self) -> Self {
        return self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }
}

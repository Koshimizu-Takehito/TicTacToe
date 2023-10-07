import Foundation

enum GameState: Hashable {
    case ongoing
    case draw
    case win(Player, positions: [IndexPath])
}

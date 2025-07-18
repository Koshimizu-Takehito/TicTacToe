import SwiftUI

/// View responsible for drawing and animating the X and O symbols.
struct SymbolGridView: View {
    @Environment(\.latticeSpacing) private var spacing
    @Environment(\.colorPalette.symbol1) private var color1
    @Environment(\.colorPalette.symbol2) private var color2
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(GameBoard.self) private var gameBoard

    /// Called when the result view is tapped.
    var onTapGameResult: () -> Void = {}
    /// Called when the win/draw animation finishes.
    var onGameResultAnimationDidFinish: () -> Void = {}

    @Namespace private var namespace
    @State private var state: AnimationState = .prepare

    var body: some View {
        ZStack {
            // X and O symbols
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing, content: symbolRows)
                .environment(\.colorPalette.symbol1, symbolColor(for: .first))
                .environment(\.colorPalette.symbol2, symbolColor(for: .second))
            // slash shown when a player wins
            Group(content: slash)
            // win or draw label
            Group(content: gameResult)
                .modifier(GameResultTapModifier(state: state, onTap: onTapGameResult))
        }
        .transaction { transaction in
            // Disable animations when the board is reset
            if gameBoard.occupied == [:] {
                transaction.animation = nil
            }
        }
        .environment(\.symbolLineWidth, symbolLineWidth)
        .onChange(of: gameBoard.occupied, redraw)
        .onChange(of: gameBoard.gameState, redraw)
    }
}

private extension SymbolGridView {
    /// Displays the winner or draw state.
    @ViewBuilder
    func gameResult() -> some View {
        if case .win = gameBoard.gameState {
            // placeholder view required for matchedGeometryEffect
            Color.clear
                .matchedGeometryEffect(id: "center", in: namespace, isSource: true)
        }

        switch (gameBoard.gameState, state) {
        case let (.win(winner, positions), .expanding):
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        ForEach(positions, id: \.self) { indexPath in
                            Color.clear
                                .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                        }
                    }
                    #if os(iOS) || os(macOS)
                        Text("WINNER!", bundle: .module)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(foregroundColor(player: winner))
                            .modifier(AdjustScaleModifier(containerSize: geometry.size))
                    #endif
                }
            }
        case (.draw, .draw):
            GeometryReader { geometry in
                let offset = max(geometry.size.width, geometry.size.height) / 10
                VStack {
                    DrawSymbolView(offset: offset)
                    #if os(iOS) || os(macOS)
                        Text("DRAW", bundle: .module)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(color1.screen(color2))
                            .modifier(AdjustScaleModifier(containerSize: geometry.size))
                    #endif
                }
                .padding(.vertical, 2 * offset)
            }
        default:
            EmptyView()
        }
    }

    /// Slash overlay shown when a player wins.
    @ViewBuilder
    func slash() -> some View {
        ForEach(Player.allCases, id: \.self) { player in
            // diagonal slashes
            ZStack {
                slash(player: player,
                      [[0, 0], [1, 1], [2, 2]],
                      [[0, 2], [1, 1], [2, 0]])
            }
            // horizontal slashes
            VStack(spacing: spacing) {
                slash(player: player,
                      [[0, 0], [0, 1], [0, 2]],
                      [[1, 0], [1, 1], [1, 2]],
                      [[2, 0], [2, 1], [2, 2]])
            }
            // vertical slashes
            HStack(spacing: spacing) {
                slash(player: player,
                      [[0, 0], [1, 0], [2, 0]],
                      [[0, 1], [1, 1], [2, 1]],
                      [[0, 2], [1, 2], [2, 2]])
            }
        }
    }

    @ViewBuilder
    func slash(player: Player, _ targets: [IndexPath]...) -> some View {
        let ratio: Double = reduceMotion ? 1 : state.isSlash ? 1 : 0
        let position: Double = state.isSlash ? 0 : 0.5
        let (winner, positions) = winnerAndPositions
        ForEach(targets, id: \.self) { target in
            let ratio: Double = positions == target && winner == player ? ratio : 0
            let opacity: Double = positions == target && winner == player && reduceMotion ? state.isSlash ? 1 : 0 : 1

            Slash(ratio: ratio, position: position, angle: angle(target))
                .stroke(lineWidth: spacing)
                .foregroundStyle(foregroundColor(player: player))
                .opacity(opacity)
                .matchedGeometryEffect(
                    id: !reduceMotion && state.isCentering ? "center" : "",
                    in: namespace,
                    isSource: false
                )
        }
    }

    /// Grid of individual symbol views.
    @ViewBuilder
    func symbolRows() -> some View {
        ForEach(0 ..< 3) { i in
            GridRow {
                ForEach(0 ..< 3) { j in
                    let indexPath: IndexPath = [i, j]
                    ZStack {
                        let positions = winnerAndPositions.positions
                        if !reduceMotion, case .centering = state, indexPath == [1, 1] {
                            ForEach(positions, id: \.self) { indexPath in
                                Color.clear
                                    .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                            }
                        }
                        SymbolView(symbol: gameBoard.symbol(at: indexPath))
                            .onTapGesture { gameBoard.place(at: indexPath) }
                            .matchedGeometryEffect(
                                id: (!reduceMotion && state.isCentering) || state.isExpanding ? indexPath : [],
                                in: namespace, isSource: false
                            )
                            .opacity(symbolOpacity(at: indexPath))
                            .sensoryFeedback(.success, trigger: gameBoard.occupied[indexPath]) { old, new in
                                switch (old, new) {
                                case (.none, .first):
                                    return gameBoard.role1 == .player
                                case (.none, .second):
                                    return gameBoard.role2 == .player
                                case _:
                                    return false
                                }
                            }
                    }
                }
            }
        }
    }

    var symbolLineWidth: Double {
        switch state {
        case .expanding:
            return spacing * 3.6
        case .draw:
            return spacing * 2.4
        default:
            return spacing
        }
    }

    func symbolOpacity(at indexPath: IndexPath) -> Double {
        switch state {
        case .prepare, .slash:
            1
        case .centering where !reduceMotion:
            winnerAndPositions.positions.contains(indexPath) ? 1 : 0
        case .expanding, .centering:
            if winnerAndPositions.positions.count == 3 {
                winnerAndPositions.positions[1] == indexPath ? 1 : 0
            } else {
                0
            }
        case .draw:
            0
        }
    }

    var winnerAndPositions: (winner: Player?, positions: [IndexPath]) {
        gameBoard.gameState.winnerAndPositions
    }
}

// MARK: - Redraw

private extension SymbolGridView {
    /// Redraws the board when the symbol placement changes.
    func redraw(old _: [IndexPath: Player], new: [IndexPath: Player]) {
        if new == [:] {
            state = .prepare
        }
    }

    /// Triggers animations when the overall game state changes.
    func redraw(old _: GameState, new: GameState) {
        Task {
            switch new {
            case .ongoing:
                state = .prepare
            case .win:
                try await Task.sleep(nanoseconds: 0_660_000_000)
                await withAnimation(.spring(duration: 0.6)) {
                    state = .slash
                }
                await withAnimation(.spring(duration: 0.5)) {
                    state = .centering
                }
                await withAnimation(.spring(duration: 0.5)) {
                    state = .expanding
                }
                try await Task.sleep(nanoseconds: 0_700_000_000)
                self.onGameResultAnimationDidFinish()
            case .draw:
                try await Task.sleep(nanoseconds: 0_660_000_000)
                await withAnimation(.spring(duration: 0.5)) {
                    state = .draw
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                self.onGameResultAnimationDidFinish()
            }
        }
    }
}

@MainActor
func withAnimation(_ animation: Animation? = .default, _ body: () -> Void) async {
    await withCheckedContinuation { continuation in
        withAnimation(animation) {
            body()
        } completion: {
            continuation.resume(returning: ())
        }
    }
}

// MARK: -

private extension SymbolGridView {
    func foregroundColor(player: Player) -> some ShapeStyle {
        switch player {
        case .first:
            color1
        case .second:
            color2
        }
    }

    func symbolColor(for player: Player) -> Color {
        let symbol = gameBoard.symbol(for: player)
        switch symbol {
        case .circle:
            return color1
        default:
            return color2
        }
    }

    /// Calculates the angle between the first and last positions.
    func angle(_ positions: [IndexPath]) -> Double {
        switch (positions.first, positions.last) {
        case let (first?, last?) where positions.count > 1:
            let p1 = CGPoint(x: last[1], y: last[0])
            let p2 = CGPoint(x: first[1], y: first[0])
            let x: Double = p1.x - p2.x
            let y: Double = p1.y - p2.y
            return atan2(y, x)
        case _:
            return 0
        }
    }
}

// MARK: -

private enum AnimationState: Hashable {
    case prepare
    case slash
    case centering
    case expanding
    case draw

    var isPrepare: Bool {
        self == .prepare
    }

    var isExpanding: Bool {
        self == .expanding
    }

    var isSlash: Bool {
        self == .slash
    }

    var isCentering: Bool {
        self == .centering
    }

    var isFinish: Bool {
        switch self {
        case .expanding, .draw:
            return true
        case _:
            return false
        }
    }
}

// MARK: -

private struct Slash: Shape, Animatable {
    var ratio: Double, position: Double, angle: Double
    /// Only the ratio property is animated.
    var animatableData: Double {
        get { ratio }
        set { ratio = newValue }
    }

    /// Creates a slash shape.
    /// - Parameters:
    ///   - ratio: Visibility ratio from 0...1
    ///   - position: Relative position of the center of the slash
    ///   - angle: Angle in radians
    init(ratio: Double, position: Double, angle: Double) {
        self.ratio = ratio
        self.position = position
        self.angle = angle
    }

    func path(in rect: CGRect) -> Path {
        let x: Double = rect.size.width / 2.0
        let y: Double = rect.size.height / 2.0
        let c: Double = abs(cos(angle))
        let s: Double = abs(sin(angle))
        let boundary: Double = abs(cos(.pi / 4.0))
        let radius: Double = (c >= boundary) ? x / c : y / s
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let p1: CGPoint = center + radius * CGPoint(x: cos(angle), y: sin(angle))
        let p2: CGPoint = center + radius * CGPoint(x: cos(angle + .pi), y: sin(angle + .pi))
        let p3: CGPoint = position * p1 + (1 - position) * p2
        var path = Path()
        path.move(to: ratio * p1 + (1 - ratio) * p3)
        path.addLine(to: ratio * p2 + (1 - ratio) * p3)
        return path
    }
}

// MARK: - 引き分けのシンボル

private struct DrawSymbolView: View {
    let offset: Double
    @State private var ratio: Double = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let symbolOffset: Double = reduceMotion ? 0 : ratio * offset
        let opacity: Double = reduceMotion ? 1 - ratio : 1
        HStack(spacing: -offset / 2) {
            SymbolView(ratio: 1, symbol: .circle)
                .offset(x: -1 * symbolOffset)
            SymbolView(ratio: 1, symbol: .cross)
                .offset(x: symbolOffset)
        }
        .padding(.horizontal, offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(reduceMotion ? .linear(duration: 0.3) : .spring(response: 0.4, dampingFraction: 0.3)) {
                ratio = 0
            }
        }
    }
}

private struct SymbolView: View {
    @State var ratio: Double = 0
    var symbol: Symbol?

    var body: some View {
        ZStack {
            Color.white.opacity(1 / 0xFFFF)
            switch symbol {
            case .circle:
                RingMark(ratio: ratio)
            case .cross:
                CrossMark(ratio: ratio)
            case .none:
                Color.clear
            }
        }
        .onChange(of: symbol) { _, _ in
            ratio = 0
            withAnimation(.spring(duration: 0.7)) {
                ratio = 1
            }
        }
    }
}

/// Handles taps on the result view after the game finishes.
private struct GameResultTapModifier: ViewModifier {
    let state: AnimationState
    let onTap: () -> Void
    @State private var canTap: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay {
                Color.white.opacity(1 / 0xFFFF)
            }
            .onTapGesture {
                if canTap {
                    canTap = false
                    onTap()
                }
            }
            .onChange(of: state, initial: true) { old, new in
                guard !old.isFinish && new.isFinish else { return }
                canTap = true
            }
    }
}

/// Adjusts scale so long text does not overflow the screen.
private struct AdjustScaleModifier: ViewModifier {
    let containerSize: CGSize
    @State var contentSize: CGSize = .zero

    func body(content: Content) -> some View {
        let scale = min(containerSize.width / contentSize.width, 1.8)
        content
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.size, initial: true) { _, new in
                            contentSize = new
                        }
                }
            }
            .scaleEffect(CGSizeMake(scale, scale))
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
#Preview(traits: .myEnvironment) {
    SymbolGridView()
        .frame(width: 330, height: 330)
        .background()
        .backgroundStyle(.mint.opacity(0.3))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        .backgroundStyle(.mint.opacity(0.3))
//        .environment(\.locale, .init(identifier: "de")) // DRAW の文字が長い
        .environment(\.locale, .init(identifier: "vi")) // WINNER! の文字が長い
}

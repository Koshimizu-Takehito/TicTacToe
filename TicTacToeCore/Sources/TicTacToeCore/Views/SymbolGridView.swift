import SwiftUI

/// まるばつのシンボルを配置する領域
struct SymbolGridView: View {
    @Environment(\.latticeSpacing) private var spacing
    @Environment(\.colorPalette.symbol1) private var color1
    @Environment(\.colorPalette.symbol2) private var color2
    @Environment(GameBoard.self) private var gameBoard

    /// ゲーム勝敗結果時のタップ
    var onTapGameResult: () -> Void = {}
    /// ゲーム勝敗結果の表示アニメーションの完了
    var onGameResultAnimationDidFinish: () -> Void = {}

    @Namespace private var namespace
    @State private var state: AnimationState = .prepare

    var body: some View {
        ZStack {
            // まるばつのシンボル
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing, content: symbolRows)
                .environment(\.colorPalette.symbol1, symbolColor(for: .first))
                .environment(\.colorPalette.symbol2, symbolColor(for: .second))
            // 勝利時のスラッシュ
            Group(content: slash)
            // 勝敗の結果
            Group(content: gameResult)
                .modifier(GameResultTapModifier(state: state, onTap: onTapGameResult))
        }
        .transaction { transaction in
            // 盤面リセット時のアニメーションを消す
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
    /// ゲームの勝敗結果
    @ViewBuilder
    func gameResult() -> some View {
        if case .win = gameBoard.gameState {
            // matchedGeometryEffect のためのダミーのビュー
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

    /// 勝敗確定時のスラッシュ
    @ViewBuilder
    func slash() -> some View {
        ForEach(Player.allCases, id: \.self) { player in
            // ナナメのスラッシュ
            ZStack {
                slash(player: player,
                      [[0, 0], [1, 1], [2, 2]],
                      [[0, 2], [1, 1], [2, 0]])
            }
            // ヨコのスラッシュ
            VStack(spacing: spacing) {
                slash(player: player,
                      [[0, 0], [0, 1], [0, 2]],
                      [[1, 0], [1, 1], [1, 2]],
                      [[2, 0], [2, 1], [2, 2]])
            }
            // タテのスラッシュ
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
        let ratio: Double = state.isSlash ? 1 : 0
        let position: Double = state.isSlash ? 0 : 0.5
        let (winner, positions) = winnerAndPositions
        ForEach(targets, id: \.self) { target in
            Slash(ratio: positions == target && winner == player ? ratio : 0, position: position, angle: angle(target))
                .stroke(lineWidth: spacing)
                .foregroundStyle(foregroundColor(player: player))
                .matchedGeometryEffect(id: state.isCentering ? "center" : "", in: namespace, isSource: false)
        }
    }

    /// まるばつの表示
    @ViewBuilder
    func symbolRows() -> some View {
        ForEach(0 ..< 3) { i in
            GridRow {
                ForEach(0 ..< 3) { j in
                    let indexPath: IndexPath = [i, j]
                    ZStack {
                        let positions = winnerAndPositions.positions
                        if case .centering = state, indexPath == [1, 1] {
                            ForEach(positions, id: \.self) { indexPath in
                                Color.clear
                                    .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                            }
                        }
                        SymbolView(symbol: gameBoard.symbol(at: indexPath))
                            .onTapGesture { gameBoard.place(at: indexPath) }
                            .matchedGeometryEffect(
                                id: state.isCentering || state.isExpanding ? indexPath : [],
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
        case .centering:
            winnerAndPositions.positions.contains(indexPath) ? 1 : 0
        case .expanding:
            winnerAndPositions.positions.first == indexPath ? 1 : 0
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
    /// シンボルの配置の状態変更を契機として再描画する
    func redraw(old _: [IndexPath: Player], new: [IndexPath: Player]) {
        if new == [:] {
            state = .prepare
        }
    }

    /// ゲームの状態変更を契機として再描画する
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

    /// ２点間距離から角度を算出する
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
    /// 表示割合のみアニメーション可能
    var animatableData: Double {
        get { ratio }
        set { ratio = newValue }
    }

    /// 初期化子
    /// - Parameters:
    ///   - ratio: 表示割合 0...1
    ///   - position: 表示の起点
    ///   - angle: 角度
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

    var body: some View {
        HStack(spacing: -offset / 2) {
            SymbolView(ratio: 1, symbol: .circle)
                .offset(x: -1 * ratio * offset)
            SymbolView(ratio: 1, symbol: .cross)
                .offset(x: ratio * offset)
        }
        .padding(.horizontal, offset)
        .onAppear {
            withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.3)) {
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

/// 勝敗の結果のタップ
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

/// 文字が長い場合に画面からはみ出さないようにスケールの値を調整する
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

#Preview {
    SymbolGridView()
        .frame(width: 330, height: 330)
        .background()
        .backgroundStyle(.mint.opacity(0.3))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        .backgroundStyle(.mint.opacity(0.3))
        .environment { board in
            board.role1 = .computer(.easy)
            board.role2 = .computer(.hard)
        }
//        .environment(\.locale, .init(identifier: "de")) // DRAW の文字が長い
        .environment(\.locale, .init(identifier: "vi")) // WINNER! の文字が長い
}

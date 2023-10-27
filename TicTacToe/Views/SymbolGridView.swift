import SwiftUI

/// まるばつのシンボルを配置する領域
struct SymbolGridView: View {
    let gameState: GameState
    let symbols: PlayerSymbolSetting
    /// 取得した陣地
    @Binding var occupied: [IndexPath: Player]
    @Environment(\.self) var environment
    @Environment(\.latticeSpacing) private var spacing
    @Environment(\.colorPalette.check1) private var color1
    @Environment(\.colorPalette.check2) private var color2
    /// 配置領域のタップ
    var onTap: (IndexPath) -> Void = { _ in }
    /// ゲーム勝敗結果時のタップ
    var onTapGameResult: () -> Void = {}
    /// ゲーム勝敗結果の表示アニメーションの完了
    var onGameResultAnimationDidFinish: () -> Void = {}

    @Namespace private var namespace
    @State private var animationState: AnimationState = .prepare

    var body: some View {
        ZStack {
            // まるばつのシンボル
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing, content: symbolRows)
            // 勝利時のスラッシュ
            Group(content: slash)
            // 勝敗の結果
            Group(content: gameResult)
                .modifier(GameResultTapModifier(state: animationState, onTap: onTapGameResult))
        }
        .transaction { transaction in
            // 盤面リセット時のアニメーションを消す
            if occupied == [:] {
                transaction.animation = nil
            }
        }
        .environment(\.symbolLineWidth, symbolLineWidth)
        .onChange(of: occupied, redraw)
        .onChange(of: gameState, redraw)
        .onChange(of: animationState, redraw)
    }
}

private extension SymbolGridView {
    /// ゲームの勝敗結果
    @ViewBuilder
    func gameResult() -> some View {
        if case .win = gameState {
            // matchedGeometryEffect のためのダミーのビュー
            Color.clear
                .matchedGeometryEffect(id: "center", in: namespace, isSource: true)
        }

        switch (gameState, animationState) {
        case (.win, .expanding(let winner, let positions)):
            VStack {
                ZStack {
                    ForEach(positions, id: \.self) { indexPath in
                        Color.clear
                            .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                    }
                }
                Text("WINNER!")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(foregroundColor(player: winner))
                    .scaleEffect(CGSizeMake(1.8, 1.8))
            }
        case (.draw, .draw):
            GeometryReader { geometry in
                let offset = max(geometry.size.width, geometry.size.height) / 10
                VStack {
                    DrawSymbolView(offset: offset)

                    Text("DRAW")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(ScreenStyle(color1, color2))
                        .scaleEffect(CGSizeMake(1.8, 1.8))
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
                       [[0,0], [1,1], [2,2]],
                       [[0,2], [1,1], [2,0]]
                )
            }
            // ヨコのスラッシュ
            VStack(spacing: spacing) {
                slash(player: player,
                       [[0,0], [0,1], [0,2]],
                       [[1,0], [1,1], [1,2]],
                       [[2,0], [2,1], [2,2]]
                )
            }
            // タテのスラッシュ
            HStack(spacing: spacing) {
                slash(player: player,
                       [[0,0], [1,0], [2,0]],
                       [[0,1], [1,1], [2,1]],
                       [[0,2], [1,2], [2,2]]
                )
            }
        }
    }

    @ViewBuilder
    func slash(player: Player, _ targets: [IndexPath]...) -> some View {
        let ratio: Double = animationState.isSlash ? 1 : 0
        let position: Double = animationState.isSlash ? 0 : 0.5
        let (winner, positions) = animationState.win
        ForEach(targets, id: \.self) { target in
            Slash(ratio: positions == target && winner == player ? ratio : 0, position: position, angle: angle(target))
                .stroke(lineWidth: spacing)
                .foregroundStyle(foregroundColor(player: player))
                .matchedGeometryEffect(id: animationState.isCentering ? "center" : "", in: namespace, isSource: false)
        }
    }

    /// まるばつの表示
    @ViewBuilder
    func symbolRows() -> some View {
        ForEach(0..<3) { i in
            GridRow {
                ForEach(0..<3) { j in
                    let indexPath: IndexPath = [i, j]
                    ZStack {
                        if case .centering(_, let positions) = animationState, indexPath == [1, 1] {
                            ForEach(positions, id: \.self) { indexPath in
                                Color.clear
                                    .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                            }
                        }
                        SymbolView(symbol: occupied[indexPath].map(symbols.symbol(for:)))
                            .onTapGesture { onTap(indexPath) }
                            .matchedGeometryEffect(id: animationState.isCentering || animationState.isExpanding ? indexPath : [], in: namespace, isSource: false)
                            .opacity(animationState.symbolOpacity(at: indexPath))
                    }
                }
            }
        }
    }

    var symbolLineWidth: Double {
        switch animationState {
        case .expanding:
            return spacing * 3.6
        case .draw:
            return spacing * 2.4
        default:
            return spacing
        }
    }
}

// MARK: - Redraw
private extension SymbolGridView {
    /// シンボルの配置の状態変更を契機として再描画する
    func redraw(old: [IndexPath: Player], new: [IndexPath: Player]) {
        if new == [:] {
            animationState = .prepare
        }
    }

    /// ゲームの状態変更を契機として再描画する
    func redraw(old: GameState, new: GameState) {
        switch new {
        case .ongoing:
            animationState = .prepare
        case .win(let player, let positions):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) {
                withAnimation(.custom()) {
                    animationState = .slash(player: player, positions: positions)
                }
            }
        case .draw:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) {
                withAnimation(.custom(duration: 0.5)) {
                    animationState = .draw
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    onGameResultAnimationDidFinish()
                }
            }
        }
    }

    /// アニメーションの状態変更を契機として再描画する
    func redraw(old: AnimationState, new: AnimationState) {
        switch (old, new) {
        case (.prepare, .slash(let player, let positions)):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.custom(duration: 0.5)) {
                    animationState = .centering(player: player, positions: positions)
                }
            }
        case (.slash, .centering(let player, let positions)):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.custom(duration: 0.5)) {
                    animationState = .expanding(player: player, positions: positions)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onGameResultAnimationDidFinish()
                }
            }
        default:
            break
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

    /// ２点間距離から角度を算出する
    func angle(_ positions: [IndexPath]) -> Double {
        switch (positions.first, positions.last) {
        case (let first?, let last?) where positions.count > 1:
            let p1: CGPoint = CGPoint(x: last[1], y: last[0])
            let p2: CGPoint = CGPoint(x: first[1], y: first[0])
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
    case slash(player: Player, positions: [IndexPath])
    case centering(player: Player, positions: [IndexPath])
    case expanding(player: Player, positions: [IndexPath])
    case draw

    var isPrepare: Bool {
        self == .prepare
    }

    var isExpanding: Bool {
        switch self {
        case .expanding:
            true
        default:
            false
        }
    }

    var isSlash: Bool {
        switch self {
        case .slash:
            true
        default:
            false
        }
    }

    var isCentering: Bool {
        switch self {
        case .centering:
            true
        default:
            false
        }
    }

    var win: (winner: Player?, positions: [IndexPath]) {
        switch self {
        case .slash(let player, let positions),
            .centering(let player, let positions),
            .expanding(let player, let positions):
            (player, positions)
        default:
            (nil, [])
        }
    }

    var isFinish: Bool {
        switch self {
        case .expanding, .draw:
            return true
        case _:
            return false
        }
    }

    func symbolOpacity(at indexPath: IndexPath) -> Double {
        switch self {
        case .prepare, .slash:
            return 1
        case .centering(_, let positions):
            return positions.contains(indexPath) ? 1 : 0
        case .expanding(_, let positions):
            return positions.first == indexPath ? 1 : 0
        case .draw:
            return 0
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
        let radius: Double = (c >= boundary) ? x/c : y/s
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
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
            Color.white.opacity(1/0xFFFF)
            switch symbol {
            case .circle:
                RingMark(ratio: ratio)
            case .cross:
                CrossMark(ratio: ratio)
            case .none:
                Color.clear
            }
        }
        .onChange(of: symbol) { oldValue, newValue in
            ratio = 0
            withAnimation(.custom()) {
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
                Color.white.opacity(1/0xFFFF)
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

struct SymbolGridView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .frame(width: 330, height: 330)
    }

    private struct Preview: View {
        let drawId = UUID()
        @State var marks: [IndexPath: Player] = [:]
        @State var state: GameState = .ongoing

        var body: some View {
            SymbolGridView(gameState: state, symbols: PlayerSymbolSetting(), occupied: $marks)
                .onAppear(perform: update)
                .backgroundStyle(Color.gray)
        }

        func update() {
            Task {
                let mark: (Player, Player) = (marks[[0, 0]] == .first)
                    ? (.second, .first)
                    : (.first, .second)
                for i in 0...2 {
                    for j in 0...2 {
                        marks[[i, j]] = (i + j) % 2 == 0 ? mark.0 : mark.1
                        try await Task.sleep(nanoseconds: 500_000_000)
                    }
                }
                state = .win(.first, positions: [[0,0], [1,1], [2,2]])
            }
        }
    }
}

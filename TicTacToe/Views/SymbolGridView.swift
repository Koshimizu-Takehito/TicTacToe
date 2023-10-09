import SwiftUI

/// タイル領域
struct SymbolGridView: View {
    let gameState: GameState
    @Binding var symbols: [IndexPath: SymbolType]
    @Environment(\.latticeSpacing) private var spacing
    @Environment(\.markColor1) private var color1
    @Environment(\.markColor2) private var color2
    var onTap: (IndexPath) -> Void = { _ in }

    @Namespace private var namespace
    @State private var animationState: AnimationState = .prepare

    var body: some View {
        ZStack {
            // 勝敗の結果
            Group(content: gameResult)
            // 勝利時のスラッシュ
            Group(content: slash)
            // まるばつのシンボル
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing, content: symbolRows)
        }
        .transaction { transaction in
            // 盤面のリセット時のアニメーションを消す
            if symbols == [:] {
                transaction.animation = nil
            }
        }
        .environment(\.markLineWidth, symbolLineWidth)
        .onChange(of: symbols, redraw)
        .onChange(of: gameState, initial: true, redraw)
        .onChange(of: animationState, redraw)
    }

    var symbolLineWidth: Double {
        switch animationState {
        case .expanding:
            return spacing * 3.6
        default:
            return spacing
        }
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
        if case .expanding(let winner, let positions) = animationState {
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
                    var opacity: Double {
                        switch animationState {
                        case .prepare, .slash:
                            return 1
                        case .centering(_, let positions):
                            return positions.contains(indexPath) ? 1 : 0
                        case .expanding(_, let positions):
                            return positions.first == indexPath ? 1 : 0
                        }
                    }
                    ZStack {
                        if case .centering(_, let positions) = animationState, indexPath == [1, 1] {
                            ForEach(positions, id: \.self) { indexPath in
                                Color.clear
                                    .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                            }
                        }
                        SymbolView(symbol: $symbols[indexPath])
                            .onTapGesture { onTap(indexPath) }
                            .matchedGeometryEffect(id: animationState.isCentering || animationState.isExpanding ? indexPath : [], in: namespace, isSource: false)
                            .opacity(opacity)
                    }
                }
            }
        }
    }

    /// シンボルの配置の状態変更を契機として再描画する
    func redraw(old: [IndexPath : SymbolType], new: [IndexPath : SymbolType]) {
        if new == [:] {
            animationState = .prepare
        }
    }

    /// ゲームの状態変更を契機として再描画する
    func redraw(old: GameState, new: GameState) {
        switch new {
        case .ongoing:
            animationState = .prepare
        case .draw:
            break
        case .win(let player, let positions):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) {
                withAnimation(.custom()) {
                    animationState = .slash(player: player, positions: positions)
                }
            }
        }
    }

    /// アニメーションの状態変更を契機として再描画する
    func redraw(old: AnimationState, new: AnimationState) {
        switch new {
        case .slash(let player, let positions):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.custom(duration: 0.5)) {
                    animationState = .centering(player: player, positions: positions)
                }
            }
        case .centering(let player, let positions):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.custom(duration: 0.5)) {
                    animationState = .expanding(player: player, positions: positions)
                }
            }
        default:
            break
        }
    }
}

private extension SymbolGridView {
    func foregroundColor(player: Player) -> Color {
        switch player {
        case .player1:
            color1
        case .player2:
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

private enum AnimationState: Hashable {
    case prepare
    case slash(player: Player, positions: [IndexPath])
    case centering(player: Player, positions: [IndexPath])
    case expanding(player: Player, positions: [IndexPath])

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
}

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

private struct SymbolView: View {
    @State var ratio: Double = 0
    @Binding var symbol: SymbolType?

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

struct SymbolGridView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .frame(width: 330, height: 330)
    }

    private struct Preview: View {
        @State var marks: [IndexPath: SymbolType] = [:]
        @State var state: GameState = .ongoing

        var body: some View {
            SymbolGridView(gameState: state, symbols: $marks)
                .onAppear(perform: update)
                .backgroundStyle(Color.gray)
        }

        func update() {
            Task {
                let mark: (SymbolType, SymbolType) = (marks[[0, 0]] == .circle)
                    ? (.cross, .circle)
                    : (.circle, .cross)
                for i in 0...2 {
                    for j in 0...2 {
                        marks[[i, j]] = (i + j) % 2 == 0 ? mark.0 : mark.1
                        try await Task.sleep(nanoseconds: 500_000_000)
                    }
                }
                state = .win(.player1, positions: [[0,0], [1,1], [2,2]])
            }
        }
    }
}

import SwiftUI

private extension MarkGridView {
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

        var win: (Player?, [IndexPath]) {
            switch self {
            case .slash(let player, let positions), .centering(let player, let positions), .expanding(let player, let positions):
                (player, positions)
            default:
                (nil, [])
            }
        }
    }
}

/// タイル領域
struct MarkGridView: View {
    let gameState: GameState
    @Binding var marks: [IndexPath: MarkType]
    @Environment(\.latticeSpacing) var spacing
    @Environment(\.markColor1) private var color1
    @Environment(\.markColor2) private var color2
    var onTap: (IndexPath) -> Void = { _ in }

    @State private var animationState: AnimationState = .prepare
    @Namespace private var namespace

    var body: some View {
        ZStack {
            Group(content: gameResult)
            Group(content: slash)
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing, content: symbols)
        }
        .onChange(of: gameState, initial: true) { old, new in
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
        .onChange(of: marks) { old, new in
            if new == [:] {
                animationState = .prepare
            }
        }
        .onChange(of: animationState) { old, new in
            switch new {
            case .slash(let player, let positions):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.custom(duration: 0.5)) {
                        animationState = .centering(player: player, positions: positions)
                    }
                }
            case .centering(let player, let positions):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.custom(duration: 0.5)) {
                        animationState = .expanding(player: player, positions: positions)
                    }
                }
            default:
                break
            }
        }
    }

    func foregroundColor(player: Player?) -> Color {
        switch player {
        case .player1:
            color1
        case .player2:
            color2
        case .none:
            .clear
        }
    }

    /// ゲームの勝敗結果
    @ViewBuilder
    func gameResult() -> some View {
        if case .win = gameState {
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
        let ratio: Double = animationState.isSlash ? 1 : 0
        let position: Double = animationState.isSlash ? 0 : 0.5
        let (winner, positions) = animationState.win
        let color = foregroundColor(player: winner)
        Group {
            Slash(ratio: ratio, position: position, angle: .pi/4)
                .stroke(lineWidth: spacing)
                .foregroundStyle(positions == [[0,0], [1,1], [2,2]] ? color : .clear)
                .matchedGeometryEffect(id: animationState.isCentering ? "center" : "", in: namespace, isSource: false)
            Slash(ratio: ratio, position: position, angle: 3 * .pi/4)
                .stroke(lineWidth: spacing)
                .foregroundStyle(positions == [[0,2], [1,1], [2,0]] ? color : .clear)
                .matchedGeometryEffect(id: animationState.isCentering ? "center" : "", in: namespace, isSource: false)
        }
        VStack(spacing: spacing) {
            let targets: [[IndexPath]] = [
                [[0,0], [0,1], [0,2]],
                [[1,0], [1,1], [1,2]],
                [[2,0], [2,1], [2,2]]
            ]
            ForEach(targets, id: \.self) { target in
                Slash(ratio: ratio, position: position, angle: 0)
                    .stroke(lineWidth: spacing)
                    .foregroundStyle(positions == target ? color : .clear)
                    .matchedGeometryEffect(id: animationState.isCentering ? "center" : "", in: namespace, isSource: false)
            }
        }
        HStack(spacing: spacing) {
            let targets: [[IndexPath]] = [
                [[0,0], [1,0], [2,0]],
                [[0,1], [1,1], [2,1]],
                [[0,2], [1,2], [2,2]]
            ]
            ForEach(targets, id: \.self) { target in
                Slash(ratio: ratio, position: position, angle: .pi/2)
                    .stroke(lineWidth: spacing)
                    .foregroundStyle(positions == target ? color : .clear)
                    .matchedGeometryEffect(id: animationState.isCentering ? "center" : "", in: namespace, isSource: false)
            }
        }
    }

    /// まるばつの表示
    @ViewBuilder
    func symbols() -> some View {
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
                        MarkView(mark: $marks[indexPath])
                            .onTapGesture { onTap(indexPath) }
                            .matchedGeometryEffect(id: animationState.isCentering || animationState.isExpanding ? indexPath : [], in: namespace, isSource: false)
                            .opacity(!animationState.isExpanding ? 1 : animationState.win.1.first == indexPath ? 1 : 0 )
                    }
                }
            }
        }
    }
}

private struct Slash: Shape, Animatable {
    var ratio: Double, position: Double, angle: Double
    var animatableData: Double {
        get { ratio }
        set { ratio = newValue }
    }

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

struct MarkView: View {
    @State var ratio: Double = 0
    @Binding var mark: MarkType?

    var body: some View {
        ZStack {
            Color.white.opacity(1/0xFFFF)
            switch mark {
            case .circle:
                RingMark(ratio: ratio)
            case .cross:
                CrossMark(ratio: ratio)
            case .none:
                Color.clear
            }
        }
        .onChange(of: mark) { oldValue, newValue in
            ratio = 0
            withAnimation(.custom()) {
                ratio = 1
            }
        }
    }
}

struct MarkView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .frame(width: 330, height: 330)
    }

    private struct Preview: View {
        @State var marks: [IndexPath: MarkType] = [:]
        @State var state: GameState = .ongoing

        var body: some View {
            MarkGridView(gameState: state, marks: $marks)
                .onAppear(perform: update)
                .backgroundStyle(Color.gray)
        }

        func update() {
            Task {
                let mark: (MarkType, MarkType) = (marks[[0, 0]] == .circle)
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

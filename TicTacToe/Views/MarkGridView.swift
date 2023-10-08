import SwiftUI

/// タイル領域
struct MarkGridView: View {
    let state: GameState
    @Binding var marks: [IndexPath: MarkType]
    @Environment(\.latticeSpacing) var spacing
    var onTap: (IndexPath) -> Void = { _ in }

    @State private var isFinish: Bool = false
    @Namespace private var namespace

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        let indexPath: IndexPath = [i, j]
                        ZStack {
                            if case .win(_, let positions) = state, indexPath == [1, 1] {
                                ForEach(positions, id: \.self) { indexPath in
                                    Color.white.opacity(1/0xFFFFFF)
                                        .matchedGeometryEffect(id: indexPath, in: namespace, isSource: true)
                                }
                            }
                            MarkView(mark: $marks[indexPath])
                                .onTapGesture { onTap(indexPath) }
                                .matchedGeometryEffect(id: isFinish ? indexPath : [], in: namespace, isSource: false)
                        }
                    }
                }
            }
        }
        .onChange(of: state, initial: true) { old, new in
            switch new {
            case .ongoing:
                isFinish = false
            case .draw, .win:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation { isFinish = true }
                }
            }
        }
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
            MarkGridView(state: state, marks: $marks)
                .onAppear(perform: update)
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
            }
        }
    }
}

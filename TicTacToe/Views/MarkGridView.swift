import SwiftUI

/// タイル領域
struct MarkGridView: View {
    @Binding var marks: [IndexPath: MarkType]
    @Environment(\.latticeSpacing) var spacing
    var onTap: (IndexPath) -> Void = { _ in }

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        let indexPath: IndexPath = [i, j]
                        MarkView(mark: $marks[indexPath])
                            .onTapGesture { onTap(indexPath) }
                    }
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
            Color.white
                .opacity(1/0xFFFF)
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
    }

    private struct Preview: View {
        @State var marks: [IndexPath: MarkType] = [:]

        var body: some View {
            MarkGridView(marks: $marks)
                .onAppear(perform: update)
        }

        func update() {
            Task {
                while true {
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
}

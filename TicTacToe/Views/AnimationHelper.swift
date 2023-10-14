import SwiftUI

struct AnimationHelper<Value: VectorArithmetic, V: View>: View {
    private let animation: Animation
    private let start: Value
    private let end: Value
    private let content: (Value) -> V
    @State var ratio: Value

    init(
        _ animation: Animation = .spring(),
        start: Value,
        end: Value,
        @ViewBuilder content: @escaping (Value) -> V
    ) {
        self.animation = animation
        self.start = start
        self.end = end
        self.content = content
        _ratio = State(initialValue: start)
    }

    var body: some View {
        ZStack {
            Color.pink
                .opacity(1/0xFFFF)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            content(ratio)
        }
        .onTapGesture(perform: perform)
        .onAppear(perform: perform)
    }

    func perform() {
        ratio = start
        withAnimation(animation) {
            ratio = end
        }
    }
}

#Preview {
    AnimationHelper(start: 0, end: 1) { parameter in
        RingMark(ratio: parameter)
    }
}

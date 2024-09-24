import SwiftUI

// MARK: - iOS
#if os(iOS) || os(macOS)
struct GameBoardView: View {
    @Environment(GameBoardViewModel.self) private var viewModel

    var body: some View {
        VStack {
            PlayerMenuView()
            GameBoardInnerView(viewModel: viewModel)
            ResetButton(action: viewModel.reset)
        }
        .padding()
        .background {
            viewModel.colorPalette.background
                .ignoresSafeArea()
        }
        .environment(\.colorPalette, viewModel.colorPalette)
    }
}

private struct ResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .buttonStyle(.titleStyle)
    }
}
#endif

// MARK: - watchOS
#if os(watchOS)
struct GameBoardView: View {
    @Environment(GameBoardViewModel.self) private var viewModel
    @State var isPresentingMenu: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                GameBoardInnerView(viewModel: viewModel)
            }
            .background {
                viewModel.colorPalette.background
                    .ignoresSafeArea()
            }
            .environment(\.colorPalette, viewModel.colorPalette)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresentingMenu = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingMenu) {
            PlayerMenuView()
        }
    }
}
#endif

@available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
#Preview(traits: .myEnvironment) {
    GameBoardView()
}

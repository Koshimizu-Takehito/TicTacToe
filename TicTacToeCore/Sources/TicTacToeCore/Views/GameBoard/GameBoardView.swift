import SwiftUI

// MARK: - iOS

#if os(iOS) || os(macOS)
    struct GameBoardView: View {
        @Environment(GameBoardViewModel.self) private var viewModel
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            @Bindable var viewModel = viewModel
            VStack(alignment: .trailing) {
                // メニュー
                PlayerMenuView()
                // 盤面
                GameBoardInnerView(viewModel: viewModel)
                // ボトムアイテム
                HStack(spacing: 0) {
                    ResetButton(action: viewModel.reset)
                    Spacer()
                    ColorSchemeSwitch(isLightMode: isLightMode)
                        .frame(width: 40, height: 40)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background { viewModel.colorPalette.background.ignoresSafeArea() }
            .environment(\.colorPalette, viewModel.colorPalette)
            .environment(\.colorScheme, viewModel.colorScheme)
            .preferredColorScheme(preferredColorScheme)
        }

        var preferredColorScheme: ColorScheme? {
#if os(iOS)
            nil
#elseif os(macOS)
            viewModel.colorScheme
#endif
        }


        var isLightMode: Binding<Bool> {
            let viewModel = viewModel
            return Binding {
                viewModel.colorScheme == .light
            } set: { isLightMode in
                withAnimation(.smooth(duration: 0.6)) {
                    viewModel.colorScheme = isLightMode ? .light : .dark
                }
            }
        }
    }

    private struct ResetButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
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

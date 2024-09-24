import SwiftUI

// MARK: - Preview

@available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
#Preview(traits: .myEnvironment) {
    @Previewable @Environment(GameBoardViewModel.self) var viewModel

    NavigationStack {
        GameBoardInnerView(viewModel: viewModel)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    EnumPicker(selection: viewModel.selection)
                        .tint(.white)
                        .dynamicTypeSize(.xxxLarge)
                }
            }
            .environment(\.colorPalette, viewModel.colorPalette)
    }
}

// MARK: - GameBoardViewModel

private extension GameBoardViewModel {
    var selection: Binding<ColorPalette.Name> {
        Binding {
            self.colorPalette.name
        } set: { name in
            self.reset(color: .init(name: name))
        }
    }
}

import SwiftUI

// MARK: - EnumPicker

struct EnumPicker<Enum>: View where
    Enum: CaseIterable & Hashable,
    Enum == Enum.AllCases.Element,
    Enum.AllCases: RandomAccessCollection
{
    @Binding var selection: Enum

    var body: some View {
        Picker(String(describing: Enum.self), selection: $selection) {
            ForEach(Enum.allCases, id: \.self) { value in
                Text(String(describing: value))
                    .tag(value)
            }
        }
    }
}

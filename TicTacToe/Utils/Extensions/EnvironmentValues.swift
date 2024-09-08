import SwiftUI

extension EnvironmentValues {
    // MARK: - 幅・スペース
    /// 格子の幅
    @Entry var symbolLineWidth: Double = 6.0
    /// 格子の幅
    @Entry var latticeSpacing: Double = 6.0

    // MARK: - 色
    /// カラーパレット
    @Entry var colorPalette: ColorPalette = .default
}

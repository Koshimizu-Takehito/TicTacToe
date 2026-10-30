import SwiftUI

#if os(iOS) || os(macOS)
    /// Arranges the player menus, the game board and the bottom controls for the available space.
    ///
    /// - vertical: menus on top, the board in the middle and the controls at the bottom.
    /// - horizontal: the board with a side column of menus and controls, used when it makes the board larger.
    /// - folded: the board on one side of the display's folding region and the menus and controls on the other.
    ///
    /// Every arrangement places the same subviews, so switching between them keeps the board's state and animations.
    struct GameBoardLayout: Layout {
        /// Folding region to keep the board clear of, in the layout's local coordinates.
        var fold: CGRect?
        var spacing: CGFloat = 8

        func sizeThatFits(proposal: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGSize {
            proposal.replacingUnspecifiedDimensions()
        }

        func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
            let parts = Parts(subviews: subviews)
            if let fold, placeFolded(parts, in: bounds, fold: fold.offsetBy(dx: bounds.minX, dy: bounds.minY)) {
                return
            }
            if horizontalBoardSide(parts, in: bounds) > verticalBoardSide(parts, in: bounds) {
                placeHorizontal(parts, in: bounds)
            } else {
                placeVertical(parts, in: bounds)
            }
        }
    }

    // MARK: - Roles

    extension GameBoardLayout {
        enum Role {
            case menu
            case board
            case controls
        }

        struct RoleKey: LayoutValueKey {
            static let defaultValue: Role = .board
        }
    }

    extension View {
        /// Tells `GameBoardLayout` how to place this view.
        func gameBoardLayoutRole(_ role: GameBoardLayout.Role) -> some View {
            layoutValue(key: GameBoardLayout.RoleKey.self, value: role)
        }
    }

    // MARK: - Arrangements

    private extension GameBoardLayout {
        struct Parts {
            var menus: [LayoutSubview] = []
            var board: LayoutSubview?
            var controls: LayoutSubview?

            init(subviews: Subviews) {
                for subview in subviews {
                    switch subview[RoleKey.self] {
                    case .menu: menus.append(subview)
                    case .board: board = subview
                    case .controls: controls = subview
                    }
                }
            }

            /// Largest ideal size among the menus.
            var menuSize: CGSize {
                menus.map { $0.sizeThatFits(.unspecified) }.reduce(.zero) {
                    CGSize(width: max($0.width, $1.width), height: max($0.height, $1.height))
                }
            }

            var controlsSize: CGSize {
                controls?.sizeThatFits(.unspecified) ?? .zero
            }

            /// Width of the column used when the menus are stacked beside the board.
            var columnWidth: CGFloat {
                max(menuSize.width, controlsSize.width)
            }
        }

        // MARK: Vertical

        func verticalBoardSide(_ parts: Parts, in bounds: CGRect) -> CGFloat {
            let height = bounds.height - rowHeight(parts, width: bounds.width) - parts.controlsSize.height - 2 * spacing
            return min(bounds.width, height)
        }

        func placeVertical(_ parts: Parts, in bounds: CGRect) {
            let rowHeight = placeMenuRow(parts, in: bounds)
            let controlsHeight = parts.controls?.sizeThatFits(.init(width: bounds.width, height: nil)).height ?? 0
            parts.controls?.place(
                at: CGPoint(x: bounds.minX, y: bounds.maxY - controlsHeight),
                proposal: .init(width: bounds.width, height: controlsHeight)
            )
            let boardHeight = max(bounds.height - rowHeight - controlsHeight - 2 * spacing, 0)
            parts.board?.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + rowHeight + spacing),
                proposal: .init(width: bounds.width, height: boardHeight)
            )
        }

        // MARK: Horizontal

        func horizontalBoardSide(_ parts: Parts, in bounds: CGRect) -> CGFloat {
            let side = min(bounds.width - parts.columnWidth - spacing, bounds.height)
            // The column must fit beside the board.
            return side >= columnHeight(parts) ? side : 0
        }

        func placeHorizontal(_ parts: Parts, in bounds: CGRect) {
            let columnWidth = parts.columnWidth
            let side = horizontalBoardSide(parts, in: bounds)
            let minX = bounds.minX + (bounds.width - side - spacing - columnWidth) / 2
            let minY = bounds.midY - side / 2
            parts.board?.place(
                at: CGPoint(x: minX, y: minY),
                proposal: .init(width: side, height: side)
            )
            placeColumn(parts, in: CGRect(x: minX + side + spacing, y: minY, width: columnWidth, height: side))
        }

        // MARK: Folded

        /// Places the board and the controls on each side of the fold. Returns `false` when they don't fit.
        func placeFolded(_ parts: Parts, in bounds: CGRect, fold: CGRect) -> Bool {
            let minimumBoardSide: CGFloat = 200
            if fold.height >= fold.width {
                // Book pose: board on the leading side, controls on the trailing side.
                let boardRect = CGRect(x: bounds.minX, y: bounds.minY, width: fold.minX - bounds.minX, height: bounds.height)
                let controlsRect = CGRect(x: fold.maxX, y: bounds.minY, width: bounds.maxX - fold.maxX, height: bounds.height)
                guard min(boardRect.width, boardRect.height) >= minimumBoardSide,
                      controlsRect.width >= parts.columnWidth,
                      controlsRect.height >= columnHeight(parts)
                else { return false }
                parts.board?.place(at: boardRect.origin, proposal: .init(boardRect.size))
                placeControlGroup(parts, in: controlsRect)
            } else {
                // Tabletop pose: board above the fold, controls below.
                let boardRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: fold.minY - bounds.minY)
                let controlsRect = CGRect(x: bounds.minX, y: fold.maxY, width: bounds.width, height: bounds.maxY - fold.maxY)
                guard min(boardRect.width, boardRect.height) >= minimumBoardSide,
                      controlsRect.width >= parts.columnWidth,
                      controlsRect.height >= controlGroupHeight(parts, width: controlsRect.width)
                else { return false }
                parts.board?.place(at: boardRect.origin, proposal: .init(boardRect.size))
                placeControlGroup(parts, in: controlsRect)
            }
            return true
        }

        /// Centers the menus and the controls in `rect`, putting the menus in a row when they fit.
        func placeControlGroup(_ parts: Parts, in rect: CGRect) {
            let height = controlGroupHeight(parts, width: rect.width)
            if fitsMenuRow(parts, width: rect.width) {
                let group = CGRect(x: rect.minX, y: rect.midY - height / 2, width: rect.width, height: height)
                let rowHeight = placeMenuRow(parts, in: group)
                parts.controls?.place(
                    at: CGPoint(x: group.minX, y: group.minY + rowHeight + spacing),
                    proposal: .init(width: group.width, height: nil)
                )
            } else {
                let width = parts.columnWidth
                placeColumn(parts, in: CGRect(x: rect.midX - width / 2, y: rect.midY - height / 2, width: width, height: height))
            }
        }

        func controlGroupHeight(_ parts: Parts, width: CGFloat) -> CGFloat {
            if fitsMenuRow(parts, width: width) {
                rowHeight(parts, width: width) + spacing + parts.controlsSize.height
            } else {
                columnHeight(parts)
            }
        }

        // MARK: Menus

        func fitsMenuRow(_ parts: Parts, width: CGFloat) -> Bool {
            CGFloat(parts.menus.count) * parts.menuSize.width <= width
        }

        func rowHeight(_ parts: Parts, width: CGFloat) -> CGFloat {
            let itemWidth = width / CGFloat(max(parts.menus.count, 1))
            return parts.menus.map { $0.sizeThatFits(.init(width: itemWidth, height: nil)).height }.max() ?? 0
        }

        /// Places the menus side by side at the top of `rect` and returns the row height.
        @discardableResult
        func placeMenuRow(_ parts: Parts, in rect: CGRect) -> CGFloat {
            let itemWidth = rect.width / CGFloat(max(parts.menus.count, 1))
            let height = rowHeight(parts, width: rect.width)
            for (index, menu) in parts.menus.enumerated() {
                menu.place(
                    at: CGPoint(x: rect.minX + CGFloat(index) * itemWidth, y: rect.minY),
                    proposal: .init(width: itemWidth, height: height)
                )
            }
            return height
        }

        func columnHeight(_ parts: Parts) -> CGFloat {
            CGFloat(parts.menus.count) * parts.menuSize.height + spacing * CGFloat(parts.menus.count) + parts.controlsSize.height
        }

        /// Stacks the menus at the top of `rect` and puts the controls at its bottom.
        func placeColumn(_ parts: Parts, in rect: CGRect) {
            let menuHeight = parts.menuSize.height
            for (index, menu) in parts.menus.enumerated() {
                menu.place(
                    at: CGPoint(x: rect.minX, y: rect.minY + CGFloat(index) * (menuHeight + spacing)),
                    proposal: .init(width: rect.width, height: menuHeight)
                )
            }
            let controlsHeight = parts.controlsSize.height
            parts.controls?.place(
                at: CGPoint(x: rect.minX, y: rect.maxY - controlsHeight),
                proposal: .init(width: rect.width, height: controlsHeight)
            )
        }
    }

    // MARK: - Folding region

    extension GeometryProxy {
        /// Frame of the display's folding region, including its margins, in local coordinates.
        ///
        /// Only an active region (the device is partially folded) is returned, so the board can use
        /// the whole display while the device is fully open.
        var foldFrame: CGRect? {
            #if os(iOS)
                if #available(iOS 27.1, *) {
                    guard let region = reservedRegions(kind: .division).first(where: \.isActive) else {
                        return nil
                    }
                    let margins = region.margins
                    return CGRect(
                        x: region.frame.minX - margins.leading,
                        y: region.frame.minY - margins.top,
                        width: region.frame.width + margins.leading + margins.trailing,
                        height: region.frame.height + margins.top + margins.bottom
                    )
                }
            #endif
            return nil
        }
    }
#endif

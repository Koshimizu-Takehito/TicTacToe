import SwiftUI

#if os(macOS)
    extension Scene {
        public func defaultSize() -> some Scene {
            defaultSize(width: 540, height: 0.8 * 540)
                .windowResizability(.contentSize)
        }
    }
#else
    extension Scene {
        public func defaultSize() -> some Scene { self }
    }
#endif

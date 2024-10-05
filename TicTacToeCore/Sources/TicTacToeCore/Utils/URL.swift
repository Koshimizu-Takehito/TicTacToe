import Foundation
import SwiftUI

public extension URL {
    static var tictactoe: Self {
        var components = URLComponents()
        components.scheme = "tictactoe"
        components.host = "tictactoe.koshimizu.takehito.com"
        components.path = "/content"
        return components.url!
    }

    func with(_ colorPalette: ColorPalette) -> Self {
        var copy = self
        copy.colorPalette = colorPalette
        return copy
    }

    func with(_ colorScheme: ColorScheme) -> Self {
        var copy = self
        copy.colorScheme = colorScheme
        return copy
    }

    var colorPalette: ColorPalette? {
        get {
            URLComponents(url: self, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first { item in item.name == "colorPalette" }?
                .value
                .flatMap(ColorPalette.Name.init(rawValue:))
                .flatMap(ColorPalette.init(name:))
        }
        set {
            guard
                let value = newValue?.name.rawValue,
                var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
            else {
                return
            }
            var queryItems = components.queryItems ?? []
            queryItems.append(.init(name: "colorPalette", value: value))
            components.queryItems = queryItems

            guard let url = components.url else { return }
            self = url
        }
    }

    var colorScheme: ColorScheme? {
        get {
            let value = URLComponents(url: self, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first { item in item.name == "colorScheme" }?
                .value
            switch value {
            case "light":
                return .light
            case "dark":
                return .dark
            default:
                return nil
            }
        }
        set {
            guard
                let newValue,
                var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
            else {
                return
            }
            var queryItems = components.queryItems ?? []
            queryItems.append(.init(name: "colorScheme", value: newValue == .light ? "light" : "dark"))
            components.queryItems = queryItems

            guard let url = components.url else { return }
            self = url
        }
    }
}

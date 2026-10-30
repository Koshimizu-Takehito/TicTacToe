# TicTacToe

![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Platform](https://img.shields.io/badge/platform-watchOS-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-6.2-orange.svg)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/TicTacToe)

Enjoy the classic game of Tic-Tac-Toe in a simple and stylish way with "TicTacToe Simple Quick Play"! This is the ultimate casual game that everyone can enjoy easily.

<a href="https://apps.apple.com/jp/app/id6470109613" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&releaseDate=1593561600&h=b17e195bc020808628890cbe7fcde25f" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Environment

- iOS 17.0+
- macOS 14.0+
- watchOS 10.0+
- Xcode Version 26.0+
- Swift 6.2+

## Setup

```bash
git clone git@github.com:Koshimizu-Takehito/TicTacToe.git
cd TicTacToe
open TicTacToe.xcworkspace
```

## Release

Xcode Cloud archives the iOS and macOS apps and uploads the builds to App Store Connect. Metadata, screenshots, and the review submission are handled with fastlane (`make help` lists the targets).

1. Copy `.env.template` to `.env`, fill in the App Store Connect API key, and run `make fastlane-setup`.
2. Bump `MARKETING_VERSION`, update `fastlane/metadata/*/release_notes.txt`, and merge to `main` so Xcode Cloud builds it.
3. `make submit-preflight VERSION=x.y.z` to check the builds have finished processing.
4. `make metadata-push VERSION=x.y.z` to create the App Store versions and upload the metadata.
5. `make submit-review VERSION=x.y.z` to submit both platforms for review (released manually after approval).

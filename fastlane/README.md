fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios pull

```sh
[bundle exec] fastlane ios pull
```

Download current metadata (from iOS) and screenshots (per platform) from App Store Connect

Warns about macOS metadata that differs from iOS, since `push` uploads the iOS text to both

### ios push

```sh
[bundle exec] fastlane ios push
```

Upload metadata, screenshots, and release notes (no binary)

Pass `version:` to create that App Store version on ASC if it doesn't exist yet; `platform:` (ios|mac) limits it to one platform

### ios submit_review_preflight

```sh
[bundle exec] fastlane ios submit_review_preflight
```

Check submission prerequisites (age rating, App Store versions, uploaded builds) without changing ASC

Usage: fastlane submit_review_preflight version:2.1.0 [platform:ios|mac]

### ios submit_review

```sh
[bundle exec] fastlane ios submit_review
```

Attach an uploaded build (e.g. from Xcode Cloud) to the version and submit it for review

Without `build:`, uses the latest processed build of that version on each platform

Usage: fastlane submit_review version:2.1.0 [build:63] [platform:ios|mac]

### ios precheck_metadata

```sh
[bundle exec] fastlane ios precheck_metadata
```

Validate the App Store Connect metadata without uploading

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

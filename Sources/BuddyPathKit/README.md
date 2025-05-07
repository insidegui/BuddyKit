# BuddyPathKit

This is a modified version of [PathKit](https://github.com/kylef/PathKit).

It renames the `Path` type to `FilePath` in order to avoid conflicts when used in a SwiftUI app.

It also adds `Sendable` conformance to `FilePath` and related types so that they work in Swift 6 mode.

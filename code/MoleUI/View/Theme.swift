import SwiftUI

// MARK: - MoleTheme

// Single source of truth for all colors, radii, and spacing.
// Swap `primary` to change the entire app's accent color.

enum MoleTheme {
    // MARK: Primary (Electric Blue-Violet)

    /// #5B66F5
    static let primary = Color(red: 0.357, green: 0.404, blue: 0.961)
    /// #4350E0
    static let primaryDark = Color(red: 0.263, green: 0.314, blue: 0.878)
    /// #ECEEFF
    static let primaryLight = Color(red: 0.925, green: 0.933, blue: 1.0)

    // MARK: Neutrals

    static let ink = Color.primary
    static let line = Color.primary.opacity(0.10)
    static let parchment = Color(nsColor: .windowBackgroundColor)
    static let sand = Color(nsColor: .underPageBackgroundColor)

    // MARK: Semantic

    /// Warm red-orange, used for destructive or cautionary accents.
    static let ember = Color(red: 0.82, green: 0.39, blue: 0.27)

    // MARK: Corner Radius Tokens

    static let radiusSm: CGFloat = 6
    static let radiusMd: CGFloat = 8
    static let radiusLg: CGFloat = 10
    static let radiusXL: CGFloat = 14

    // MARK: Legacy Aliases

    // Keeps upstream callers that reference the old green palette compiling.
    static var pine: Color { primary }
    static var pineDeep: Color { primaryDark }
    static var moss: Color { primaryDark }
    static var meadow: Color { primaryLight }
    static var sky: Color { primary }
}

import SwiftUI

enum Theme {
    // MARK: - Colors
    enum Colors {
        static let accent = Color(red: 56/255, green: 189/255, blue: 248/255) // #38bdf8
        static let accentGlow = accent.opacity(0.1)

        static let background = Color(red: 12/255, green: 25/255, blue: 41/255) // #0c1929
        static let backgroundGradientEnd = Color(red: 13/255, green: 31/255, blue: 61/255) // #0d1f3d

        static let cardBackground = Color.white.opacity(0.05)
        static let cardBorder = Color.white.opacity(0.08)
        static let cardBackgroundHover = Color.white.opacity(0.07)

        static let sidebarBackground = Color.white.opacity(0.03)
        static let sidebarBorder = Color.white.opacity(0.06)

        static let sidebarIconBackground = Color.white.opacity(0.04)
        static let sidebarIconBorder = Color.white.opacity(0.06)
        static let sidebarIconActiveBackground = accent.opacity(0.15)
        static let sidebarIconActiveBorder = accent.opacity(0.3)

        static let textPrimary = Color.white.opacity(0.94)
        static let textSecondary = Color.white.opacity(0.55)
        static let textMuted = Color.white.opacity(0.33)
        static let textDone = Color.white.opacity(0.33)

        static let checkboxBorder = Color.white.opacity(0.15)
        static let checkboxCheckedBackground = accent.opacity(0.15)
        static let checkboxCheckedBorder = accent.opacity(0.4)

        static let progressBarBackground = Color.white.opacity(0.06)
        static let progressBarFill = accent

        static let statusGreen = Color(red: 74/255, green: 222/255, blue: 128/255)
        static let statusOrange = Color(red: 251/255, green: 146/255, blue: 60/255)
        static let statusRed = Color(red: 248/255, green: 113/255, blue: 113/255)

        static let badgeBackground = accent.opacity(0.08)
        static let badgeBorder = accent.opacity(0.15)
        static let badgeText = accent.opacity(0.8)

        static let addButtonBorder = Color.white.opacity(0.08)
        static let addButtonText = Color.white.opacity(0.2)

        static let inputBackground = accent.opacity(0.05)
        static let inputBorder = accent.opacity(0.1)
    }

    // MARK: - Dimensions
    enum Dimensions {
        static let popoverWidth: CGFloat = 380
        static let popoverMinHeight: CGFloat = 400
        static let sidebarWidth: CGFloat = 56
        static let sidebarIconSize: CGFloat = 34
        static let sidebarIconCornerRadius: CGFloat = 9
        static let cardCornerRadius: CGFloat = 10
        static let checkboxSize: CGFloat = 18
        static let checkboxCornerRadius: CGFloat = 5
        static let contentPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 6
    }

    // MARK: - Font
    static func manrope(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Manrope", size: size).weight(weight)
    }
}

// MARK: - Glassmorphic Card Modifier
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}

import SwiftUI

enum Theme {
    enum Colors {
        // Accent — Fresh Blue
        static let accent = Color(red: 0.23, green: 0.65, blue: 1.0) // #3AA6FF
        static let accentSecondary = Color(red: 0.0, green: 0.81, blue: 1.0) // #00CFFF
        static let accentTertiary = Color(red: 0.18, green: 0.84, blue: 0.45) // #2ED573
        static let accentGradient = LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Background — fresh teal gradient
        static let bgTop = Color(red: 0.059, green: 0.125, blue: 0.153) // #0F2027
        static let bgMid = Color(red: 0.125, green: 0.227, blue: 0.263) // #203A43
        static let bgBottom = Color(red: 0.173, green: 0.325, blue: 0.392) // #2C5364
        static let background = bgTop

        // Glass — cyan-tinted
        static let glassTint = Color(red: 0, green: 0.78, blue: 1.0).opacity(0.06)
        static let glassBorder = Color.white.opacity(0.25)
        static let glassBorderHover = Color.white.opacity(0.35)

        // Text — friendly, not harsh
        static let textPrimary = Color(red: 0.973, green: 0.98, blue: 0.988) // #F8FAFC
        static let textSecondary = Color.white.opacity(0.75)
        static let textMuted = Color.white.opacity(0.45)
        static let textDone = Color.white.opacity(0.40)

        // Sidebar
        static let sidebarBorder = Color.white.opacity(0.08)

        // Checkbox
        static let checkboxBorder = Color.white.opacity(0.30)

        // Status — emotional + clear
        static let statusGreen = Color(red: 0.18, green: 0.84, blue: 0.45) // #2ED573
        static let statusOrange = Color(red: 1.0, green: 0.82, blue: 0.40) // #FFD166
        static let statusRed = Color(red: 1.0, green: 0.42, blue: 0.42)    // #FF6B6B

        // Input
        static let inputBorder = Color.white.opacity(0.15)
        static let inputFocusBorder = accent.opacity(0.6)
    }

    enum Dimensions {
        static let panelWidth: CGFloat = 440
        static let sidebarWidth: CGFloat = 78
        static let sidebarIconSize: CGFloat = 40
        static let sidebarIconCornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 18
        static let checkboxSize: CGFloat = 22
        static let contentPadding: CGFloat = 18
        static let cardSpacing: CGFloat = 8
        static let popoverWidth: CGFloat = panelWidth
        static let popoverMinHeight: CGFloat = 500
    }

    static func manrope(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Manrope", size: size).weight(weight)
    }
}

// MARK: - Glass Card
struct GlassCard: ViewModifier {
    var highlight: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                        .fill(Theme.Colors.glassTint)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                    .stroke(
                        highlight ? Theme.Colors.glassBorderHover : Theme.Colors.glassBorder,
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(highlight: Bool = false) -> some View {
        modifier(GlassCard(highlight: highlight))
    }
}

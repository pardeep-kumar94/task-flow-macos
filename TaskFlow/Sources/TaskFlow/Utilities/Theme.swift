import SwiftUI
import AppKit

enum Theme {
    enum Colors {
        // Accent — follows the user's macOS System Settings accent color
        static let accent = Color.accentColor
        static let accentSecondary = Color(nsColor: .controlAccentColor).opacity(0.75)
        static let accentTertiary = Color(nsColor: .systemTeal)
        static let accentGradient = LinearGradient(
            colors: [Color.accentColor, Color.accentColor.opacity(0.70)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Background — system-adaptive (light/dark aware)
        static let bgTop = Color(nsColor: .windowBackgroundColor)
        static let bgMid = Color(nsColor: .windowBackgroundColor)
        static let bgBottom = Color(nsColor: .underPageBackgroundColor)
        static let background = bgTop

        // Surfaces — subtle overlays that read correctly on any material
        static let glassTint = Color(nsColor: .controlBackgroundColor).opacity(0.5)
        static let glassBorder = Color(nsColor: .separatorColor)
        static let glassBorderHover = Color(nsColor: .controlAccentColor).opacity(0.45)

        // Text — system semantic labels
        static let textPrimary = Color(nsColor: .labelColor)
        static let textSecondary = Color(nsColor: .secondaryLabelColor)
        static let textMuted = Color(nsColor: .tertiaryLabelColor)
        static let textDone = Color(nsColor: .quaternaryLabelColor)

        // Sidebar
        static let sidebarBorder = Color(nsColor: .separatorColor)

        // Checkbox
        static let checkboxBorder = Color(nsColor: .tertiaryLabelColor)

        // Status — system semantic status colors
        static let statusGreen = Color(nsColor: .systemGreen)
        static let statusOrange = Color(nsColor: .systemOrange)
        static let statusRed = Color(nsColor: .systemRed)

        // Input
        static let inputBorder = Color(nsColor: .separatorColor)
        static let inputFocusBorder = Color.accentColor.opacity(0.6)

        // Neutral track (progress rings, capsules) — adapts to appearance
        static let track = Color(nsColor: .quaternaryLabelColor).opacity(0.5)
    }

    enum Dimensions {
        static let panelWidth: CGFloat = 440
        static let sidebarWidth: CGFloat = 78
        static let sidebarIconSize: CGFloat = 40
        static let sidebarIconCornerRadius: CGFloat = 10
        static let cardCornerRadius: CGFloat = 12
        static let checkboxSize: CGFloat = 20
        static let contentPadding: CGFloat = 18
        static let cardSpacing: CGFloat = 6
        static let popoverWidth: CGFloat = panelWidth
        static let popoverMinHeight: CGFloat = 500
    }

    static func manrope(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Manrope", size: size).weight(weight)
    }
}

// MARK: - Glass Card (native macOS surface)
struct GlassCard: ViewModifier {
    var highlight: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                    .stroke(
                        highlight ? Theme.Colors.glassBorderHover : Theme.Colors.glassBorder,
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

extension View {
    func glassCard(highlight: Bool = false) -> some View {
        modifier(GlassCard(highlight: highlight))
    }
}

// MARK: - NSVisualEffectView bridge (for true macOS materials like .sidebar)
struct VisualEffect: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .followsWindowActiveState

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

import SwiftUI

enum SidebarTab: String, CaseIterable {
    case today, history, goals, notes, settings

    var icon: String {
        switch self {
        case .today: "sun.max.fill"
        case .history: "clock.fill"
        case .goals: "flame.fill"
        case .notes: "note.text"
        case .settings: "gearshape.fill"
        }
    }

    var label: String {
        switch self {
        case .today: "Today"
        case .history: "History"
        case .goals: "Goals"
        case .notes: "Notes"
        case .settings: "Settings"
        }
    }

    var isBottom: Bool { self == .settings }
}

struct SidebarView: View {
    @Binding var selectedTab: SidebarTab

    var body: some View {
        VStack(spacing: 4) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.Colors.accentGradient)
                    .frame(width: 32, height: 32)
                Text("T")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 14)

            ForEach(SidebarTab.allCases.filter { !$0.isBottom }, id: \.self) { tab in
                sidebarIcon(tab)
            }
            Spacer()
            ForEach(SidebarTab.allCases.filter { $0.isBottom }, id: \.self) { tab in
                sidebarIcon(tab)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(width: Theme.Dimensions.sidebarWidth)
        .background(VisualEffect(material: .sidebar, blendingMode: .behindWindow))
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(Theme.Colors.sidebarBorder),
            alignment: .trailing
        )
    }

    private func sidebarIcon(_ tab: SidebarTab) -> some View {
        let isActive = selectedTab == tab
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Dimensions.sidebarIconCornerRadius, style: .continuous)
                        .fill(isActive ? Theme.Colors.accent.opacity(0.18) : Color.clear)
                        .frame(width: Theme.Dimensions.sidebarIconSize, height: Theme.Dimensions.sidebarIconSize)

                    Image(systemName: tab.icon)
                        .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                }

                Text(tab.label)
                    .font(.system(size: 9, weight: isActive ? .semibold : .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundColor(isActive ? Theme.Colors.accent : Theme.Colors.textSecondary)
    }
}

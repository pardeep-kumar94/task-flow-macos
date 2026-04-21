import SwiftUI

enum SidebarTab: String, CaseIterable {
    case today
    case goals
    case notes
    case settings

    var icon: String {
        switch self {
        case .today: "checkmark"
        case .goals: "target"
        case .notes: "square.and.pencil"
        case .settings: "gearshape"
        }
    }

    var isBottom: Bool {
        self == .settings
    }
}

struct SidebarView: View {
    @Binding var selectedTab: SidebarTab

    var body: some View {
        VStack(spacing: 10) {
            ForEach(SidebarTab.allCases.filter { !$0.isBottom }, id: \.self) { tab in
                sidebarIcon(tab)
            }
            Spacer()
            ForEach(SidebarTab.allCases.filter { $0.isBottom }, id: \.self) { tab in
                sidebarIcon(tab)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 7)
        .frame(width: Theme.Dimensions.sidebarWidth)
        .background(Theme.Colors.sidebarBackground)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Theme.Colors.sidebarBorder),
            alignment: .trailing
        )
    }

    private func sidebarIcon(_ tab: SidebarTab) -> some View {
        let isActive = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            Image(systemName: tab.icon)
                .font(.system(size: 14))
                .frame(width: Theme.Dimensions.sidebarIconSize, height: Theme.Dimensions.sidebarIconSize)
                .background(isActive ? Theme.Colors.sidebarIconActiveBackground : Theme.Colors.sidebarIconBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.sidebarIconCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Dimensions.sidebarIconCornerRadius)
                        .stroke(isActive ? Theme.Colors.sidebarIconActiveBorder : Theme.Colors.sidebarIconBorder, lineWidth: 1)
                )
                .shadow(color: isActive ? Theme.Colors.accentGlow : .clear, radius: 6)
        }
        .buttonStyle(.plain)
        .foregroundColor(isActive ? Theme.Colors.accent : Theme.Colors.textMuted)
    }
}

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SidebarTab = .today

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedTab: $selectedTab)

            Group {
                switch selectedTab {
                case .today:
                    TodayView()
                case .goals:
                    Text("Goals View")
                        .foregroundColor(Theme.Colors.textPrimary)
                        .font(Theme.manrope(14))
                case .notes:
                    Text("Notes View")
                        .foregroundColor(Theme.Colors.textPrimary)
                        .font(Theme.manrope(14))
                case .settings:
                    Text("Settings View")
                        .foregroundColor(Theme.Colors.textPrimary)
                        .font(Theme.manrope(14))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: Theme.Dimensions.popoverWidth)
        .frame(minHeight: Theme.Dimensions.popoverMinHeight)
        .background(
            LinearGradient(
                colors: [Theme.Colors.background, Theme.Colors.backgroundGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

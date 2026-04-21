import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: SidebarTab = .today
    var iconManager: MenuBarIconManager

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedTab: $selectedTab)

            Group {
                switch selectedTab {
                case .today:
                    TodayView()
                case .goals:
                    GoalsView()
                case .notes:
                    NotesView()
                case .settings:
                    SettingsView()
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
        .onAppear {
            iconManager.update(modelContext: modelContext)
        }
    }
}

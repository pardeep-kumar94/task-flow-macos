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
                case .history:
                    HistoryView()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.windowBackground)
        .onAppear {
            iconManager.update(modelContext: modelContext)
        }
    }
}

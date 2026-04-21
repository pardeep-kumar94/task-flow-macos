import SwiftUI
import SwiftData

// Note: Global keyboard shortcut (Cmd+Shift+T) to toggle the popover
// requires NSStatusItem-based approach. MenuBarExtra doesn't support this natively.
// This is logged as a future enhancement.

@main
struct TaskFlowApp: App {
    @State private var iconManager = MenuBarIconManager()

    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            ContentView(iconManager: iconManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [
            DailyTask.self,
            Goal.self,
            GoalSubTask.self,
            QuickNote.self
        ])
    }
}

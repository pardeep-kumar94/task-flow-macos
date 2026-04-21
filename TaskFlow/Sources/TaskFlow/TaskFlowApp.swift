import SwiftUI
import SwiftData

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

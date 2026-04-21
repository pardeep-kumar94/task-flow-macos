import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            ContentView()
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

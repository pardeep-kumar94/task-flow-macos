import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    var body: some Scene {
        MenuBarExtra("TaskFlow", systemImage: "checklist") {
            Text("TaskFlow — Coming Soon")
                .padding()
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

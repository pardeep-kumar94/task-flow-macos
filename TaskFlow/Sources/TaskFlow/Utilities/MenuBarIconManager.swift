import SwiftUI
import SwiftData

@Observable
final class MenuBarIconManager {
    var statusColor: Color = Theme.Colors.statusGreen

    func update(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        let overdueDescriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date < today && task.isCompleted == false
            }
        )

        let todayDescriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date == today
            }
        )

        do {
            let overdueTasks = try modelContext.fetch(overdueDescriptor)
            let todayTasks = try modelContext.fetch(todayDescriptor)

            if !overdueTasks.isEmpty {
                statusColor = Theme.Colors.statusRed
            } else if todayTasks.isEmpty || todayTasks.allSatisfy(\.isCompleted) {
                statusColor = Theme.Colors.statusGreen
            } else {
                statusColor = Theme.Colors.statusOrange
            }
        } catch {
            statusColor = Theme.Colors.statusGreen
        }
    }
}

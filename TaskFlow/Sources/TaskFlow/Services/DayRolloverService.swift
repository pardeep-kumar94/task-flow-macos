import Foundation
import SwiftData
import Observation

@Observable
final class DayRolloverService {
    var hasUnresolvedRollover = false
    var pendingTasks: [DailyTask] = []

    private var timer: Timer?

    func checkRollover(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        let descriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date < today && task.isCompleted == false
            }
        )

        do {
            let incompleteTasks = try modelContext.fetch(descriptor)
            if !incompleteTasks.isEmpty {
                pendingTasks = incompleteTasks
                hasUnresolvedRollover = true
            } else {
                pendingTasks = []
                hasUnresolvedRollover = false
            }
        } catch {
            pendingTasks = []
            hasUnresolvedRollover = false
        }
    }

    func carryForward(tasks: [DailyTask], modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        for task in tasks {
            let newTask = DailyTask(title: task.title, date: today, sortOrder: task.sortOrder)
            modelContext.insert(newTask)
        }
        // Delete all pending tasks (carried or not)
        for task in pendingTasks {
            modelContext.delete(task)
        }
        try? modelContext.save()
        hasUnresolvedRollover = false
        pendingTasks = []
    }

    func clearAll(modelContext: ModelContext) {
        for task in pendingTasks {
            modelContext.delete(task)
        }
        try? modelContext.save()
        hasUnresolvedRollover = false
        pendingTasks = []
    }

    func startPeriodicCheck(modelContext: ModelContext) {
        checkRollover(modelContext: modelContext)
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkRollover(modelContext: modelContext)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

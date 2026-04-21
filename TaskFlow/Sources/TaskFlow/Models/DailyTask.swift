import Foundation
import SwiftData

@Model
final class DailyTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var date: Date
    var createdAt: Date
    var sortOrder: Int

    init(title: String, date: Date = .now, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.date = Calendar.current.startOfDay(for: date)
        self.createdAt = .now
        self.sortOrder = sortOrder
    }
}

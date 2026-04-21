import Foundation
import SwiftData

@Model
final class GoalSubTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    var goal: Goal?

    init(title: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.sortOrder = sortOrder
    }
}

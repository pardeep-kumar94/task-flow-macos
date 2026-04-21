import Foundation
import SwiftData

enum GoalTimeframe: String, Codable, CaseIterable {
    case threeMonth = "3 Month"
    case sixMonth = "6 Month"
    case oneYear = "1 Year"

    var sortOrder: Int {
        switch self {
        case .threeMonth: 0
        case .sixMonth: 1
        case .oneYear: 2
        }
    }
}

@Model
final class Goal {
    var id: UUID
    var title: String
    var timeframe: GoalTimeframe
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \GoalSubTask.goal)
    var subTasks: [GoalSubTask]

    init(title: String, timeframe: GoalTimeframe) {
        self.id = UUID()
        self.title = title
        self.timeframe = timeframe
        self.createdAt = .now
        self.subTasks = []
    }

    var completedSubTaskCount: Int {
        subTasks.filter(\.isCompleted).count
    }

    var progress: Double {
        guard !subTasks.isEmpty else { return 0 }
        return Double(completedSubTaskCount) / Double(subTasks.count)
    }
}

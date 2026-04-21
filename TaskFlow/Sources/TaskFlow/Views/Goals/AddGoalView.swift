import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    var onAdded: () -> Void

    var body: some View {
        Button(action: addGoal) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                Text("Add goal")
                    .font(Theme.manrope(12, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Theme.Colors.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                    .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func addGoal() {
        guard let result = InputDialog.showGoalDialog() else { return }

        let timeframe: GoalTimeframe
        switch result.timeframe {
        case "6 Month": timeframe = .sixMonth
        case "1 Year": timeframe = .oneYear
        default: timeframe = .threeMonth
        }

        let goal = Goal(title: result.title, timeframe: timeframe)
        modelContext.insert(goal)
        try? modelContext.save()
        onAdded()
    }
}

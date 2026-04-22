import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    var onAdded: () -> Void

    var body: some View {
        Button(action: addGoal) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.accent)
                Text("Add goal")
                    .font(Theme.manrope(13, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                    .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 0.5)
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

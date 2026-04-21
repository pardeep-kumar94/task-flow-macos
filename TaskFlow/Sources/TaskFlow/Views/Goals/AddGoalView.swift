import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var timeframe: GoalTimeframe = .threeMonth
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Goal")
                .font(Theme.manrope(13, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)

            TextField("Goal title", text: $title)
                .textFieldStyle(.plain)
                .font(Theme.manrope(13))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Theme.Colors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                        .stroke(Theme.Colors.inputBorder, lineWidth: 1)
                )

            HStack(spacing: 6) {
                ForEach(GoalTimeframe.allCases, id: \.self) { tf in
                    Button(action: { timeframe = tf }) {
                        Text(tf.rawValue)
                            .font(Theme.manrope(11, weight: .semibold))
                            .foregroundColor(timeframe == tf ? Theme.Colors.accent : Theme.Colors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(timeframe == tf ? Theme.Colors.sidebarIconActiveBackground : Theme.Colors.sidebarIconBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(timeframe == tf ? Theme.Colors.sidebarIconActiveBorder : Theme.Colors.sidebarIconBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Button("Cancel") { onDismiss() }
                    .font(Theme.manrope(11, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .buttonStyle(.plain)

                Spacer()

                Button("Add") { addGoal() }
                    .font(Theme.manrope(11, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.sidebarIconActiveBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.Colors.sidebarIconActiveBorder, lineWidth: 1)
                    )
                    .buttonStyle(.plain)
            }
        }
        .padding(12)
        .glassCard()
    }

    private func addGoal() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let goal = Goal(title: trimmed, timeframe: timeframe)
        modelContext.insert(goal)
        onDismiss()
    }
}

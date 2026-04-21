import SwiftUI

struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(goal.title)
                .font(Theme.manrope(13, weight: .medium))
                .foregroundColor(Theme.Colors.textPrimary)

            if !goal.subTasks.isEmpty {
                HStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.Colors.progressBarBackground)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Colors.accent.opacity(0.6), Theme.Colors.accent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * goal.progress, height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text("\(goal.completedSubTaskCount)/\(goal.subTasks.count)")
                        .font(Theme.manrope(10, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(minWidth: 30, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }
}

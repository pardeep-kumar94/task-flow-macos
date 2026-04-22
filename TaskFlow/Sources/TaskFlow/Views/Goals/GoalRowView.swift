import SwiftUI

struct GoalRowView: View {
    let goal: Goal
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(Theme.manrope(13, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                if !goal.subTasks.isEmpty {
                    Text("\(goal.completedSubTaskCount)/\(goal.subTasks.count)")
                        .font(Theme.manrope(10, weight: .bold))
                        .foregroundColor(Theme.Colors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 0.5))
                }
            }

            if !goal.subTasks.isEmpty {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 4)
                        Capsule()
                            .fill(Theme.Colors.accent)
                            .frame(width: max(4, geo.size.width * goal.progress), height: 4)
                            .shadow(color: Theme.Colors.accent.opacity(0.4), radius: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(highlight: isHovered)
        .onHover { isHovered = $0 }
    }
}

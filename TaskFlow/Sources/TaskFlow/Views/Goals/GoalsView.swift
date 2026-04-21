import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allGoals: [Goal]
    @State private var selectedGoal: Goal?
    @State private var refreshID = UUID()

    private func goals(for timeframe: GoalTimeframe) -> [Goal] {
        allGoals
            .filter { $0.timeframe == timeframe }
            .sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        if let goal = selectedGoal {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { selectedGoal = nil }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Back")
                                .font(Theme.manrope(11, weight: .semibold))
                        }
                        .foregroundColor(Theme.Colors.accent)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.Dimensions.contentPadding)
                    .padding(.top, 12)
                    Spacer()
                }
                GoalDetailView(goal: goal)
            }
        } else {
            goalsList
                .id(refreshID)
        }
    }

    private var goalsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Goals")
                        .font(Theme.manrope(15, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("\(allGoals.count) active goals")
                        .font(Theme.manrope(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(GoalTimeframe.allCases, id: \.self) { timeframe in
                        let tfGoals = goals(for: timeframe)

                        Text(timeframe.rawValue)
                            .font(Theme.manrope(10, weight: .bold))
                            .foregroundColor(Theme.Colors.accent.opacity(0.5))
                            .textCase(.uppercase)
                            .tracking(0.8)
                            .padding(.horizontal, Theme.Dimensions.contentPadding)
                            .padding(.top, timeframe == .threeMonth ? 0 : 12)
                            .padding(.bottom, 8)

                        VStack(spacing: Theme.Dimensions.cardSpacing) {
                            ForEach(tfGoals) { goal in
                                Button(action: { selectedGoal = goal }) {
                                    GoalRowView(goal: goal)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        withAnimation {
                                            modelContext.delete(goal)
                                            try? modelContext.save()
                                            refreshID = UUID()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Dimensions.contentPadding)
                    }

                    // Add goal
                    AddGoalView(onAdded: { refreshID = UUID() })
                        .padding(.horizontal, Theme.Dimensions.contentPadding)
                        .padding(.top, 12)
                }
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }
}

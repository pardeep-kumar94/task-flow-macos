import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allGoals: [Goal]
    @State private var selectedGoal: Goal?
    @State private var refreshID = UUID()

    private func goals(for timeframe: GoalTimeframe) -> [Goal] {
        allGoals.filter { $0.timeframe == timeframe }.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        if let goal = selectedGoal {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { withAnimation { selectedGoal = nil } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
                            Text("Back").font(Theme.manrope(12, weight: .semibold))
                        }
                        .foregroundColor(Theme.Colors.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.Dimensions.contentPadding)
                    .padding(.top, 12)
                    Spacer()
                }
                GoalDetailView(goal: goal)
            }
        } else {
            goalsList.id(refreshID)
        }
    }

    private var goalsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Goals")
                    .font(Theme.manrope(22, weight: .bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text("\(allGoals.count) active goals")
                    .font(Theme.manrope(12, weight: .medium))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, 20)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(GoalTimeframe.allCases, id: \.self) { timeframe in
                        let tfGoals = goals(for: timeframe)

                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Theme.Colors.accent)
                                .frame(width: 3, height: 12)
                            Text(timeframe.rawValue)
                                .font(Theme.manrope(10, weight: .bold))
                                .foregroundColor(Theme.Colors.accent)
                                .textCase(.uppercase)
                                .tracking(1)
                        }
                        .padding(.horizontal, Theme.Dimensions.contentPadding)
                        .padding(.top, timeframe == .threeMonth ? 0 : 16)
                        .padding(.bottom, 8)

                        VStack(spacing: Theme.Dimensions.cardSpacing) {
                            ForEach(tfGoals) { goal in
                                Button(action: { withAnimation(.spring(response: 0.3)) { selectedGoal = goal } }) {
                                    GoalRowView(goal: goal)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        withAnimation { modelContext.delete(goal); try? modelContext.save(); refreshID = UUID() }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Dimensions.contentPadding)
                    }

                    AddGoalView(onAdded: { refreshID = UUID() })
                        .padding(.horizontal, Theme.Dimensions.contentPadding)
                        .padding(.top, 16)
                }
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }
}

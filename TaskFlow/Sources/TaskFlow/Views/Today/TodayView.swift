import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]
    @State private var rolloverService = DayRolloverService()
    @State private var refreshID = UUID()

    private var todayTasks: [DailyTask] {
        let today = Calendar.current.startOfDay(for: .now)
        return allTasks
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var completedCount: Int {
        todayTasks.filter(\.isCompleted).count
    }

    private var completionPercent: Int {
        guard !todayTasks.isEmpty else { return 0 }
        return Int(Double(completedCount) / Double(todayTasks.count) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(Theme.manrope(15, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("\(todayTasks.count) tasks · \(completedCount) done")
                        .font(Theme.manrope(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
                if !todayTasks.isEmpty {
                    Text("\(completionPercent)%")
                        .font(Theme.manrope(10, weight: .semibold))
                        .foregroundColor(Theme.Colors.badgeText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.Colors.badgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Theme.Colors.badgeBorder, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            // Task list
            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    if rolloverService.hasUnresolvedRollover {
                        DayRolloverView(
                            tasks: rolloverService.pendingTasks,
                            onKeepSelected: { tasks in
                                rolloverService.carryForward(tasks: tasks, modelContext: modelContext)
                            },
                            onClearAll: {
                                rolloverService.clearAll(modelContext: modelContext)
                            }
                        )
                        .padding(.bottom, 8)
                    }

                    ForEach(todayTasks) { task in
                        TaskRowView(task: task)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    modelContext.delete(task)
                                    try? modelContext.save()
                                    refreshID = UUID()
                                }
                            }
                    }

                    // Add task button
                    Button(action: addTask) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.accent)
                            Text("Add task")
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
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
        .id(refreshID)
        .onAppear { rolloverService.startPeriodicCheck(modelContext: modelContext) }
        .onDisappear { rolloverService.stop() }
    }

    private func addTask() {
        guard let title = InputDialog.show(
            title: "New Task",
            message: "Enter the task name:",
            placeholder: "Task name"
        ) else { return }

        let task = DailyTask(title: title, sortOrder: todayTasks.count)
        modelContext.insert(task)
        try? modelContext.save()
        refreshID = UUID()
    }
}

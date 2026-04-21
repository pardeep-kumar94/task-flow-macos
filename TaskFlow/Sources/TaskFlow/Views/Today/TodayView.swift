import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]
    @State private var newTaskTitle = ""
    @State private var isAddingTask = false
    @State private var rolloverService = DayRolloverService()

    private var todayTasks: [DailyTask] {
        let today = Calendar.current.startOfDay(for: .now)
        return allTasks
            .filter { $0.date == today }
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
                                    withAnimation {
                                        modelContext.delete(task)
                                    }
                                }
                            }
                    }

                    // Add task
                    if isAddingTask {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)

                            TextField("Task name", text: $newTaskTitle)
                                .textFieldStyle(.plain)
                                .font(Theme.manrope(13))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .onSubmit {
                                    addTask()
                                }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassCard()
                    } else {
                        Button(action: { isAddingTask = true }) {
                            Text("+ Add task")
                                .font(Theme.manrope(12, weight: .medium))
                                .foregroundColor(Theme.Colors.addButtonText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                                        .stroke(Theme.Colors.addButtonBorder, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
        .onAppear { rolloverService.startPeriodicCheck(modelContext: modelContext) }
        .onDisappear { rolloverService.stop() }
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            isAddingTask = false
            return
        }
        let task = DailyTask(title: title, sortOrder: todayTasks.count)
        modelContext.insert(task)
        newTaskTitle = ""
        isAddingTask = false
    }
}

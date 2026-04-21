import SwiftUI
import SwiftData
import AppKit

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]
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
                                        try? modelContext.save()
                                    }
                                }
                            }
                    }

                    // Add task button
                    Button(action: { showAddTaskDialog() }) {
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
        .onAppear { rolloverService.startPeriodicCheck(modelContext: modelContext) }
        .onDisappear { rolloverService.stop() }
    }

    private func showAddTaskDialog() {
        let alert = NSAlert()
        alert.messageText = "New Task"
        alert.informativeText = "Enter the task name:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        textField.placeholderString = "Task name"
        alert.accessoryView = textField
        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let title = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return }
            let task = DailyTask(title: title, sortOrder: todayTasks.count)
            modelContext.insert(task)
            try? modelContext.save()
        }
    }
}

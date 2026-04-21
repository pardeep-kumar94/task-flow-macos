import SwiftUI
import SwiftData
import AppKit

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    private var sortedSubTasks: [GoalSubTask] {
        goal.subTasks.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(goal.title)
                    .font(Theme.manrope(15, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Text(goal.timeframe.rawValue)
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
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            // Sub-tasks
            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    ForEach(sortedSubTasks) { subTask in
                        subTaskRow(subTask)
                    }

                    Button(action: { showAddSubTaskDialog() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.accent)
                            Text("Add sub-task")
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
    }

    private func subTaskRow(_ subTask: GoalSubTask) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    subTask.isCompleted.toggle()
                    try? modelContext.save()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                        .fill(subTask.isCompleted ? Theme.Colors.checkboxCheckedBackground : Color.clear)
                        .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(subTask.isCompleted ? Theme.Colors.checkboxCheckedBorder : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                        )

                    if subTask.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(subTask.title)
                .font(Theme.manrope(13))
                .foregroundColor(subTask.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                .strikethrough(subTask.isCompleted, color: Theme.Colors.textDone)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }

    private func showAddSubTaskDialog() {
        let alert = NSAlert()
        alert.messageText = "New Sub-task"
        alert.informativeText = "Enter the sub-task name:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        textField.placeholderString = "Sub-task name"
        alert.accessoryView = textField
        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let title = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return }
            let subTask = GoalSubTask(title: title, sortOrder: goal.subTasks.count)
            subTask.goal = goal
            modelContext.insert(subTask)
            try? modelContext.save()
        }
    }
}

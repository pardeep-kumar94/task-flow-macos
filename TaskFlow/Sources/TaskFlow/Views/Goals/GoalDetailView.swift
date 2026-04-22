import SwiftUI
import SwiftData
import AppKit

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal
    @State private var newSubTaskTitle = ""
    @FocusState private var isInputFocused: Bool

    private var sortedSubTasks: [GoalSubTask] {
        goal.subTasks.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(Theme.manrope(18, weight: .bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    if !goal.subTasks.isEmpty {
                        Text("\(goal.completedSubTaskCount) of \(goal.subTasks.count) completed")
                            .font(Theme.manrope(12))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                Spacer()
                Text(goal.timeframe.rawValue)
                    .font(Theme.manrope(10, weight: .bold))
                    .foregroundColor(Theme.Colors.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 0.5))
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            // Input
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.accent)
                TextField("Add sub-task...", text: $newSubTaskTitle)
                    .textFieldStyle(.plain)
                    .font(Theme.manrope(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .focused($isInputFocused)
                    .onSubmit { addSubTask() }
                if !newSubTaskTitle.isEmpty {
                    Button(action: addSubTask) {
                        Text("Add")
                            .font(Theme.manrope(11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Theme.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isInputFocused ? Theme.Colors.inputFocusBorder : Theme.Colors.inputBorder, lineWidth: 0.5)
            )
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    ForEach(sortedSubTasks) { subTask in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(subTask.isCompleted ? Theme.Colors.accent.opacity(0.15) : Color.clear)
                                    .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                                Circle()
                                    .stroke(subTask.isCompleted ? Theme.Colors.accent : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                    .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                                if subTask.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                            .contentShape(Circle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    subTask.isCompleted.toggle()
                                    try? modelContext.save()
                                }
                            }

                            Text(subTask.title)
                                .font(Theme.manrope(13, weight: subTask.isCompleted ? .regular : .medium))
                                .foregroundColor(subTask.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                                .strikethrough(subTask.isCompleted, color: Theme.Colors.textDone)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .glassCard()
                    }

                    if sortedSubTasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checklist")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(Theme.Colors.accent.opacity(0.5))
                            Text("No sub-tasks yet")
                                .font(Theme.manrope(13, weight: .semibold))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func addSubTask() {
        let title = newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        withAnimation(.spring(response: 0.3)) {
            let subTask = GoalSubTask(title: title, sortOrder: goal.subTasks.count)
            subTask.goal = goal
            modelContext.insert(subTask)
            try? modelContext.save()
            newSubTaskTitle = ""
        }
    }
}

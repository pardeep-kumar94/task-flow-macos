import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: DailyTask
    @Binding var editingTaskID: PersistentIdentifier?
    @State private var isHovered = false
    @State private var editText = ""
    @FocusState private var isEditFocused: Bool

    private var isEditing: Bool {
        editingTaskID == task.persistentModelID
    }

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            ZStack {
                Circle()
                    .fill(task.isCompleted ? Theme.Colors.accent.opacity(0.15) : Color.clear)
                    .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                Circle()
                    .stroke(
                        task.isCompleted ? Theme.Colors.accent : Theme.Colors.checkboxBorder,
                        lineWidth: 1.5
                    )
                    .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)

                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.Colors.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    task.isCompleted.toggle()
                    try? modelContext.save()
                }
            }

            if isEditing {
                TextField("Task title", text: $editText)
                    .textFieldStyle(.plain)
                    .font(Theme.manrope(13, weight: .medium))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .focused($isEditFocused)
                    .onSubmit { commitEdit() }
                    .onExitCommand { cancelEdit() }
                    .onAppear {
                        editText = task.title
                        isEditFocused = true
                    }
            } else {
                Text(task.title)
                    .font(Theme.manrope(13, weight: task.isCompleted ? .regular : .medium))
                    .foregroundColor(task.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                    .strikethrough(task.isCompleted, color: Theme.Colors.textDone)
            }

            Spacer()

            if isEditing {
                HStack(spacing: 6) {
                    Button(action: commitEdit) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.statusGreen)
                    }
                    .buttonStyle(.plain)

                    Button(action: cancelEdit) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.textMuted)
                    }
                    .buttonStyle(.plain)
                }
            } else if !task.isCompleted {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 6, height: 6)
                    .shadow(color: Theme.Colors.accent.opacity(0.5), radius: 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(highlight: isHovered || isEditing)
        .onHover { isHovered = $0 }
    }

    private func commitEdit() {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            task.title = trimmed
            try? modelContext.save()
        }
        editingTaskID = nil
    }

    private func cancelEdit() {
        editingTaskID = nil
    }
}

import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: DailyTask
    @State private var isHovered = false

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

            Text(task.title)
                .font(Theme.manrope(13, weight: task.isCompleted ? .regular : .medium))
                .foregroundColor(task.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                .strikethrough(task.isCompleted, color: Theme.Colors.textDone)

            Spacer()

            if !task.isCompleted {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 6, height: 6)
                    .shadow(color: Theme.Colors.accent.opacity(0.5), radius: 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(highlight: isHovered)
        .onHover { isHovered = $0 }
    }
}

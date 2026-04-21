import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: DailyTask

    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    task.isCompleted.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                        .fill(task.isCompleted ? Theme.Colors.checkboxCheckedBackground : Color.clear)
                        .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                .stroke(task.isCompleted ? Theme.Colors.checkboxCheckedBorder : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(Theme.manrope(13))
                .foregroundColor(task.isCompleted ? Theme.Colors.textDone : Theme.Colors.textPrimary)
                .strikethrough(task.isCompleted, color: Theme.Colors.textDone)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }
}

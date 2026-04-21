import SwiftUI

struct DayRolloverView: View {
    let tasks: [DailyTask]
    var onKeepSelected: ([DailyTask]) -> Void
    var onClearAll: () -> Void

    @State private var selectedTaskIds: Set<UUID>

    init(tasks: [DailyTask], onKeepSelected: @escaping ([DailyTask]) -> Void, onClearAll: @escaping () -> Void) {
        self.tasks = tasks
        self.onKeepSelected = onKeepSelected
        self.onClearAll = onClearAll
        self._selectedTaskIds = State(initialValue: Set(tasks.map(\.id)))
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Carry forward?")
                .font(Theme.manrope(13, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)

            VStack(spacing: 4) {
                ForEach(tasks) { task in
                    HStack(spacing: 10) {
                        Button(action: { toggleTask(task) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                    .fill(selectedTaskIds.contains(task.id) ? Theme.Colors.checkboxCheckedBackground : Color.clear)
                                    .frame(width: Theme.Dimensions.checkboxSize, height: Theme.Dimensions.checkboxSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Dimensions.checkboxCornerRadius)
                                            .stroke(selectedTaskIds.contains(task.id) ? Theme.Colors.checkboxCheckedBorder : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                    )

                                if selectedTaskIds.contains(task.id) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Text(task.title)
                            .font(Theme.manrope(12))
                            .foregroundColor(selectedTaskIds.contains(task.id) ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassCard()
                }
            }

            HStack(spacing: 8) {
                Button(action: {
                    let selected = tasks.filter { selectedTaskIds.contains($0.id) }
                    onKeepSelected(selected)
                }) {
                    Text("Keep Selected")
                        .font(Theme.manrope(11, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.sidebarIconActiveBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.Colors.sidebarIconActiveBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button(action: onClearAll) {
                    Text("Clear All")
                        .font(Theme.manrope(11, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Theme.Colors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                .stroke(Theme.Colors.inputBorder, lineWidth: 1)
        )
    }

    private func toggleTask(_ task: DailyTask) {
        if selectedTaskIds.contains(task.id) {
            selectedTaskIds.remove(task.id)
        } else {
            selectedTaskIds.insert(task.id)
        }
    }
}

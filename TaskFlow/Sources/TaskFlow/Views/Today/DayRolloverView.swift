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
            HStack(spacing: 8) {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.statusOrange)
                Text("Carry forward?")
                    .font(Theme.manrope(13, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
            }

            VStack(spacing: 4) {
                ForEach(tasks) { task in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(selectedTaskIds.contains(task.id) ? Theme.Colors.accent.opacity(0.15) : Color.clear)
                                .frame(width: 18, height: 18)
                            Circle()
                                .stroke(selectedTaskIds.contains(task.id) ? Theme.Colors.accent : Theme.Colors.checkboxBorder, lineWidth: 1.5)
                                .frame(width: 18, height: 18)
                            if selectedTaskIds.contains(task.id) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                        .contentShape(Circle())
                        .onTapGesture { toggleTask(task) }

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
                        .font(Theme.manrope(11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: onClearAll) {
                    Text("Clear All")
                        .font(Theme.manrope(11, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .glassCard(highlight: true)
    }

    private func toggleTask(_ task: DailyTask) {
        if selectedTaskIds.contains(task.id) {
            selectedTaskIds.remove(task.id)
        } else {
            selectedTaskIds.insert(task.id)
        }
    }
}

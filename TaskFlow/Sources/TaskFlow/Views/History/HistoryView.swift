import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]

    private var groupedTasks: [(date: Date, tasks: [DailyTask])] {
        let completedTasks = allTasks.filter(\.isCompleted)

        let grouped = Dictionary(grouping: completedTasks) { task in
            Calendar.current.startOfDay(for: task.date)
        }

        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, tasks: $0.value.sorted { $0.sortOrder < $1.sortOrder }) }
    }

    private var totalCompleted: Int { allTasks.filter(\.isCompleted).count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(Theme.manrope(22, weight: .bold))
                    .foregroundColor(Theme.Colors.textPrimary)

                HStack(spacing: 8) {
                    statPill(icon: "checkmark.circle.fill", text: "\(totalCompleted) completed", color: Theme.Colors.statusGreen)
                    statPill(icon: "calendar", text: "\(groupedTasks.count) days", color: Theme.Colors.accent)
                }
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Task list grouped by date
            ScrollView(showsIndicators: false) {
                if groupedTasks.isEmpty {
                    emptyState
                } else {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(groupedTasks, id: \.date) { group in
                            dateSection(date: group.date, tasks: group.tasks)
                        }
                    }
                    .padding(.bottom, Theme.Dimensions.contentPadding)
                }
            }
        }
    }

    private func dateSection(date: Date, tasks: [DailyTask]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Dimensions.cardSpacing) {
            // Date header
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Theme.Colors.accentGradient)
                    .frame(width: 3, height: 14)

                Text(formattedDate(date))
                    .font(Theme.manrope(12, weight: .bold))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Text("\(tasks.count) done")
                    .font(Theme.manrope(10, weight: .bold))
                    .foregroundColor(Theme.Colors.statusGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.Colors.statusGreen.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, 14)
            .padding(.bottom, 6)

            ForEach(tasks) { task in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.statusGreen.opacity(0.12))
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.statusGreen)
                    }

                    Text(task.title)
                        .font(Theme.manrope(13))
                        .foregroundColor(Theme.Colors.textDone)
                        .strikethrough(true, color: Theme.Colors.textDone)

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .glassCard()
                .padding(.horizontal, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func statPill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(Theme.manrope(10, weight: .semibold))
        }
        .foregroundColor(color.opacity(0.8))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.08))
        .clipShape(Capsule())
    }

    private func formattedDate(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            return "Today"
        }
        if cal.isDateInYesterday(date) {
            return "Yesterday"
        }
        let daysAgo = cal.dateComponents([.day], from: cal.startOfDay(for: date), to: cal.startOfDay(for: .now)).day ?? 0
        if daysAgo < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.08))
                    .frame(width: 64, height: 64)
                Image(systemName: "clock.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Theme.Colors.accentGradient)
            }

            Text("No history yet")
                .font(Theme.manrope(16, weight: .bold))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("Completed tasks will show up here")
                .font(Theme.manrope(12))
                .foregroundColor(Theme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
}

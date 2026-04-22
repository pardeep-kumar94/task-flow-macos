import SwiftUI
import SwiftData

struct DesktopWidgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]
    @State private var currentTime = Date.now
    @State private var isHovered = false
    var onClose: () -> Void

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var todayTasks: [DailyTask] {
        let today = Calendar.current.startOfDay(for: .now)
        return allTasks
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var completedCount: Int { todayTasks.filter(\.isCompleted).count }
    private var pendingTasks: [DailyTask] { Array(todayTasks.filter { !$0.isCompleted }.prefix(5)) }
    private var completionPercent: Double {
        guard !todayTasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(todayTasks.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Clock
            VStack(alignment: .leading, spacing: 2) {
                Text(currentTime, format: .dateTime.hour().minute())
                    .font(.system(size: 38, weight: .thin, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .monospacedDigit()
                Text(currentTime, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .font(Theme.manrope(12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5).padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Today")
                        .font(Theme.manrope(11, weight: .bold))
                        .foregroundColor(.white.opacity(0.35))
                        .textCase(.uppercase).tracking(1.2)
                    Spacer()
                    if !todayTasks.isEmpty {
                        Text("\(completedCount)/\(todayTasks.count)")
                            .font(Theme.manrope(11, weight: .bold))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }

                if !todayTasks.isEmpty {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08)).frame(height: 3)
                            Capsule().fill(Theme.Colors.accent)
                                .frame(width: max(3, geo.size.width * completionPercent), height: 3)
                                .shadow(color: Theme.Colors.accent.opacity(0.5), radius: 4)
                        }
                    }.frame(height: 3)
                }

                if pendingTasks.isEmpty && todayTasks.isEmpty {
                    Text("No tasks for today")
                        .font(Theme.manrope(12)).foregroundColor(.white.opacity(0.3)).padding(.top, 4)
                } else if pendingTasks.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.Colors.statusGreen).font(.system(size: 14))
                        Text("All done!").font(Theme.manrope(13, weight: .medium)).foregroundColor(Theme.Colors.statusGreen)
                    }.padding(.top, 4)
                } else {
                    VStack(spacing: 6) {
                        ForEach(pendingTasks) { task in
                            HStack(spacing: 8) {
                                Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5).frame(width: 14, height: 14)
                                Text(task.title).font(Theme.manrope(12)).foregroundColor(.white.opacity(0.75)).lineLimit(1)
                                Spacer()
                            }
                        }
                    }
                }

                let remaining = todayTasks.filter({ !$0.isCompleted }).count
                if remaining > 5 {
                    Text("+\(remaining - 5) more")
                        .font(Theme.manrope(10, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .frame(width: 280)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.bgTop.opacity(0.7), Theme.Colors.bgBottom.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(isHovered ? 0.15 : 0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
        .overlay(alignment: .topTrailing) {
            if isHovered {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 22, height: 22)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .padding(10)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { isHovered = $0 }
        .onReceive(timer) { currentTime = $0 }
    }
}

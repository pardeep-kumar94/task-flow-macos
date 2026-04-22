import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [DailyTask]
    @State private var rolloverService = DayRolloverService()
    @State private var newTaskTitle = ""
    @State private var editingTaskID: PersistentIdentifier?
    @FocusState private var isInputFocused: Bool

    private var todayTasks: [DailyTask] {
        let today = Calendar.current.startOfDay(for: .now)
        return allTasks
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var completedCount: Int { todayTasks.filter(\.isCompleted).count }

    private var completionPercent: Double {
        guard !todayTasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(todayTasks.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greetingText)
                            .font(Theme.manrope(22, weight: .bold))
                            .foregroundColor(Theme.Colors.textPrimary)

                        Text(Date.now, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                            .font(Theme.manrope(12, weight: .medium))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    Spacer()

                    if !todayTasks.isEmpty {
                        // Completion ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 3)
                                .frame(width: 44, height: 44)
                            Circle()
                                .trim(from: 0, to: completionPercent)
                                .stroke(Theme.Colors.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 44, height: 44)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.5), value: completionPercent)
                            Text("\(Int(completionPercent * 100))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.accent)
                        }
                    }
                }

                HStack(spacing: 8) {
                    statPill(icon: "list.bullet", text: "\(todayTasks.count) tasks", color: Theme.Colors.accent)
                    statPill(icon: "checkmark.circle.fill", text: "\(completedCount) done", color: Theme.Colors.statusGreen)
                    if todayTasks.count - completedCount > 0 {
                        statPill(icon: "clock", text: "\(todayTasks.count - completedCount) left", color: Theme.Colors.statusOrange)
                    }
                }
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Input
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.accent)

                TextField("What needs to be done?", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(Theme.manrope(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .focused($isInputFocused)
                    .onSubmit { addTask() }

                if !newTaskTitle.isEmpty {
                    Button(action: addTask) {
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
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        Color.white.opacity(isInputFocused ? 0.20 : 0.08),
                        lineWidth: 0.5
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isInputFocused)
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            // Tasks
            ScrollView(showsIndicators: false) {
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
                        .padding(.bottom, 4)
                    }

                    ForEach(todayTasks) { task in
                        TaskRowView(task: task, editingTaskID: $editingTaskID)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                            .contextMenu {
                                Button("Edit") {
                                    editingTaskID = task.persistentModelID
                                }
                                Button("Delete", role: .destructive) {
                                    withAnimation(.spring(response: 0.3)) {
                                        modelContext.delete(task)
                                        try? modelContext.save()
                                    }
                                }
                            }
                    }

                    if todayTasks.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 36, weight: .light))
                                .foregroundColor(Theme.Colors.accent.opacity(0.5))
                            Text("All clear!")
                                .font(Theme.manrope(16, weight: .bold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Add your first task to get started")
                                .font(Theme.manrope(12))
                                .foregroundColor(Theme.Colors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
        .onAppear { rolloverService.startPeriodicCheck(modelContext: modelContext) }
        .onDisappear { rolloverService.stop() }
    }

    private func statPill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 9, weight: .semibold))
            Text(text).font(Theme.manrope(10, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.2), lineWidth: 0.5))
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        withAnimation(.spring(response: 0.3)) {
            let task = DailyTask(title: title, sortOrder: todayTasks.count)
            modelContext.insert(task)
            try? modelContext.save()
            newTaskTitle = ""
        }
    }
}

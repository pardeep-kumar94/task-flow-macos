import SwiftUI
import SwiftData
import ServiceManagement

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("rolloverHour") private var rolloverHour = 0
    @State private var showExportSuccess = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(Theme.manrope(15, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.top, Theme.Dimensions.contentPadding)
                .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    // Launch at login
                    settingRow {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Launch at Login")
                                    .font(Theme.manrope(13, weight: .medium))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("Start TaskFlow when you log in")
                                    .font(Theme.manrope(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $launchAtLogin)
                                .toggleStyle(.switch)
                                .tint(Theme.Colors.accent)
                                .labelsHidden()
                                .onChange(of: launchAtLogin) { _, newValue in
                                    do {
                                        if newValue {
                                            try SMAppService.mainApp.register()
                                        } else {
                                            try SMAppService.mainApp.unregister()
                                        }
                                    } catch {
                                        launchAtLogin = !newValue
                                    }
                                }
                        }
                    }

                    // Rollover time
                    settingRow {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Day Rollover Time")
                                    .font(Theme.manrope(13, weight: .medium))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("When the new day starts")
                                    .font(Theme.manrope(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Picker("", selection: $rolloverHour) {
                                Text("Midnight").tag(0)
                                Text("3:00 AM").tag(3)
                                Text("5:00 AM").tag(5)
                                Text("6:00 AM").tag(6)
                            }
                            .labelsHidden()
                            .frame(width: 110)
                            .tint(Theme.Colors.accent)
                        }
                    }

                    // Export data
                    settingRow {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data")
                                    .font(Theme.manrope(13, weight: .medium))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("Save all data as JSON")
                                    .font(Theme.manrope(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Button(action: exportData) {
                                Text(showExportSuccess ? "Saved!" : "Export")
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
                        }
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func settingRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassCard()
    }

    private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "taskflow-export.json"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let tasks = try modelContext.fetch(FetchDescriptor<DailyTask>())
            let goals = try modelContext.fetch(FetchDescriptor<Goal>())
            let notes = try modelContext.fetch(FetchDescriptor<QuickNote>())

            let export: [String: Any] = [
                "exportDate": ISO8601DateFormatter().string(from: .now),
                "tasks": tasks.map { ["id": $0.id.uuidString, "title": $0.title, "isCompleted": $0.isCompleted, "date": ISO8601DateFormatter().string(from: $0.date)] },
                "goals": goals.map { ["id": $0.id.uuidString, "title": $0.title, "timeframe": $0.timeframe.rawValue, "subTasks": $0.subTasks.map { ["title": $0.title, "isCompleted": $0.isCompleted] }] },
                "notes": notes.map { ["id": $0.id.uuidString, "text": $0.text, "createdAt": ISO8601DateFormatter().string(from: $0.createdAt)] }
            ]

            let data = try JSONSerialization.data(withJSONObject: export, options: .prettyPrinted)
            try data.write(to: url)

            showExportSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showExportSuccess = false
            }
        } catch {
            // Export failed silently
        }
    }
}

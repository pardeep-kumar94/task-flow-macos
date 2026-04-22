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
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(Theme.manrope(22, weight: .bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text("Preferences")
                    .font(Theme.manrope(12, weight: .medium))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, 20)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    settingRow(icon: "power", iconColor: Theme.Colors.statusGreen) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Launch at Login").font(Theme.manrope(13, weight: .medium)).foregroundColor(Theme.Colors.textPrimary)
                                Text("Start TaskFlow when you log in").font(Theme.manrope(11)).foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $launchAtLogin)
                                .toggleStyle(.switch).tint(Theme.Colors.accent).labelsHidden()
                                .onChange(of: launchAtLogin) { _, v in
                                    do { if v { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() } }
                                    catch { launchAtLogin = !v }
                                }
                        }
                    }

                    settingRow(icon: "clock", iconColor: Theme.Colors.statusOrange) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Day Rollover Time").font(Theme.manrope(13, weight: .medium)).foregroundColor(Theme.Colors.textPrimary)
                                Text("When the new day starts").font(Theme.manrope(11)).foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Picker("", selection: $rolloverHour) {
                                Text("Midnight").tag(0); Text("3:00 AM").tag(3); Text("5:00 AM").tag(5); Text("6:00 AM").tag(6)
                            }.labelsHidden().frame(width: 110).tint(Theme.Colors.accent)
                        }
                    }

                    settingRow(icon: "square.and.arrow.up", iconColor: Theme.Colors.accent) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data").font(Theme.manrope(13, weight: .medium)).foregroundColor(Theme.Colors.textPrimary)
                                Text("Save all data as JSON").font(Theme.manrope(11)).foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            Button(action: exportData) {
                                Text(showExportSuccess ? "Saved!" : "Export")
                                    .font(Theme.manrope(11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Theme.Colors.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func settingRow<Content: View>(icon: String, iconColor: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(iconColor.opacity(0.2), lineWidth: 0.5))
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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
            try JSONSerialization.data(withJSONObject: export, options: .prettyPrinted).write(to: url)
            showExportSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showExportSuccess = false }
        } catch {}
    }
}

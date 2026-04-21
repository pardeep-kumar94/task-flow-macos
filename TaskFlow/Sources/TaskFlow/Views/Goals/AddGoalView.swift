import SwiftUI
import SwiftData
import AppKit

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    var onDismiss: () -> Void

    var body: some View {
        Button(action: { showAddGoalDialog() }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)
                Text("Add goal")
                    .font(Theme.manrope(12, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Theme.Colors.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                    .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func showAddGoalDialog() {
        let alert = NSAlert()
        alert.messageText = "New Goal"
        alert.informativeText = "Enter goal title and select timeframe:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 60))

        let textField = NSTextField(frame: NSRect(x: 0, y: 32, width: 260, height: 24))
        textField.placeholderString = "Goal title"
        container.addSubview(textField)

        let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        popup.addItems(withTitles: ["3 Month", "6 Month", "1 Year"])
        container.addSubview(popup)

        alert.accessoryView = container
        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let title = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return }

            let timeframe: GoalTimeframe
            switch popup.indexOfSelectedItem {
            case 0: timeframe = .threeMonth
            case 1: timeframe = .sixMonth
            default: timeframe = .oneYear
            }

            let goal = Goal(title: title, timeframe: timeframe)
            modelContext.insert(goal)
            try? modelContext.save()
            onDismiss()
        }
    }
}

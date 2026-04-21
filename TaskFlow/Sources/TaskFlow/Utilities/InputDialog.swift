import AppKit

struct InputDialog {
    static func show(title: String, message: String, placeholder: String = "") -> String? {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        textField.placeholderString = placeholder
        alert.accessoryView = textField
        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return nil }

        let value = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    static func showGoalDialog() -> (title: String, timeframe: String)? {
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
        guard response == .alertFirstButtonReturn else { return nil }

        let title = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }

        let timeframes = ["3 Month", "6 Month", "1 Year"]
        let timeframe = timeframes[popup.indexOfSelectedItem]
        return (title, timeframe)
    }
}

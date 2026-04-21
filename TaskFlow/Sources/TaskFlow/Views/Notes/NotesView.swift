import SwiftUI
import SwiftData
import AppKit

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickNote.createdAt, order: .reverse) private var notes: [QuickNote]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notes")
                        .font(Theme.manrope(15, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("Brain dump")
                        .font(Theme.manrope(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, Theme.Dimensions.contentPadding)
            .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    // Add note button
                    Button(action: { showAddNoteDialog() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.Colors.accent)
                            Text("Quick note")
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

                    // Notes list
                    ForEach(notes) { note in
                        NoteRowView(note: note) {
                            withAnimation {
                                modelContext.delete(note)
                                try? modelContext.save()
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
    }

    private func showAddNoteDialog() {
        let alert = NSAlert()
        alert.messageText = "Quick Note"
        alert.informativeText = "Jot something down:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        textField.placeholderString = "Note text"
        alert.accessoryView = textField
        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let text = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            let note = QuickNote(text: text)
            modelContext.insert(note)
            try? modelContext.save()
        }
    }
}

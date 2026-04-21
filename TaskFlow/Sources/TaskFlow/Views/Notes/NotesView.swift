import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickNote.createdAt, order: .reverse) private var notes: [QuickNote]
    @State private var newNoteText = ""

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
                    // Input field
                    TextField("Type a quick note...", text: $newNoteText)
                        .textFieldStyle(.plain)
                        .font(Theme.manrope(12, weight: .medium))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                                .stroke(Theme.Colors.inputBorder, lineWidth: 1)
                        )
                        .onSubmit { addNote() }

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

    private func addNote() {
        let text = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let note = QuickNote(text: text)
        modelContext.insert(note)
        try? modelContext.save()
        newNoteText = ""
    }
}

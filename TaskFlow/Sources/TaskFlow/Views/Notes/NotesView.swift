import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickNote.createdAt, order: .reverse) private var notes: [QuickNote]
    @State private var newNoteText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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

            // Input
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accent)

                TextField("Jot something down...", text: $newNoteText)
                    .textFieldStyle(.plain)
                    .font(Theme.manrope(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .onSubmit { addNote() }

                if !newNoteText.isEmpty {
                    Button("Save") { addNote() }
                        .font(Theme.manrope(11, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Theme.Colors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius)
                    .stroke(Theme.Colors.inputBorder, lineWidth: 1)
            )
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    ForEach(notes) { note in
                        NoteRowView(note: note) {
                            modelContext.delete(note)
                            try? modelContext.save()
                        }
                    }

                    if notes.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .font(.system(size: 32))
                                .foregroundColor(Theme.Colors.textMuted)
                            Text("No notes yet")
                                .font(Theme.manrope(13))
                                .foregroundColor(Theme.Colors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
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

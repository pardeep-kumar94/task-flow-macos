import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickNote.createdAt, order: .reverse) private var notes: [QuickNote]
    @State private var newNoteText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(Theme.manrope(22, weight: .bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text("\(notes.count) notes")
                    .font(Theme.manrope(12, weight: .medium))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.top, 20)
            .padding(.bottom, 16)

            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.accent)
                TextField("Jot something down...", text: $newNoteText)
                    .textFieldStyle(.plain)
                    .font(Theme.manrope(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .focused($isInputFocused)
                    .onSubmit { addNote() }
                if !newNoteText.isEmpty {
                    Button(action: addNote) {
                        Text("Save")
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
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isInputFocused ? Theme.Colors.inputFocusBorder : Theme.Colors.inputBorder, lineWidth: 0.5)
            )
            .padding(.horizontal, Theme.Dimensions.contentPadding)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    ForEach(notes) { note in
                        NoteRowView(note: note) {
                            withAnimation(.spring(response: 0.3)) {
                                modelContext.delete(note); try? modelContext.save()
                            }
                        }
                    }
                    if notes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "note.text")
                                .font(.system(size: 36, weight: .light))
                                .foregroundColor(Theme.Colors.accent.opacity(0.5))
                            Text("No notes yet")
                                .font(Theme.manrope(15, weight: .semibold))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
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
        withAnimation(.spring(response: 0.3)) {
            modelContext.insert(QuickNote(text: text)); try? modelContext.save(); newNoteText = ""
        }
    }
}

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickNote.createdAt, order: .reverse) private var notes: [QuickNote]
    @State private var refreshID = UUID()

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

            ScrollView {
                VStack(spacing: Theme.Dimensions.cardSpacing) {
                    Button(action: addNote) {
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

                    ForEach(notes) { note in
                        NoteRowView(note: note) {
                            modelContext.delete(note)
                            try? modelContext.save()
                            refreshID = UUID()
                        }
                    }
                }
                .padding(.horizontal, Theme.Dimensions.contentPadding)
                .padding(.bottom, Theme.Dimensions.contentPadding)
            }
        }
        .id(refreshID)
    }

    private func addNote() {
        guard let text = InputDialog.show(
            title: "Quick Note",
            message: "Jot something down:",
            placeholder: "Note text"
        ) else { return }

        let note = QuickNote(text: text)
        modelContext.insert(note)
        try? modelContext.save()
        refreshID = UUID()
    }
}

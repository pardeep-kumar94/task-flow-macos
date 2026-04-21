import SwiftUI

struct NoteRowView: View {
    let note: QuickNote
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.text)
                    .font(Theme.manrope(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(3)

                Text(note.relativeTimestamp)
                    .font(Theme.manrope(10, weight: .medium))
                    .foregroundColor(Theme.Colors.textMuted)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Theme.Colors.textMuted)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .opacity(0.5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }
}

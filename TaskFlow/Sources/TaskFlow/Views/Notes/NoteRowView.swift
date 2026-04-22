import SwiftUI

struct NoteRowView: View {
    let note: QuickNote
    var onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Theme.Colors.accent)
                .frame(width: 3)
                .padding(.vertical, 2)

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

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.Colors.statusRed.opacity(0.8))
                        .frame(width: 24, height: 24)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(highlight: isHovered)
        .onHover { h in withAnimation(.easeInOut(duration: 0.15)) { isHovered = h } }
    }
}

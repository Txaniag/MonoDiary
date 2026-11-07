import SwiftUI

struct EntryRow: View {
    let entry: DiaryEntry
    let colors: ThemeColors

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            dateBlock

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    Text(entry.displayTitle)
                        .font(.system(.headline, design: .serif, weight: .semibold))
                        .foregroundStyle(colors.text)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if !entry.trimmedContent.isEmpty {
                        Text("\(entry.trimmedContent.count) 字")
                            .font(.system(.caption2, design: .serif))
                            .foregroundStyle(colors.tertiaryText)
                    }
                }

                if !entry.trimmedContent.isEmpty {
                    Text(entry.trimmedContent)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: 8) {
                    MoodTag(mood: entry.mood, colors: colors)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(colors.tertiaryText)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(12)
        .background(colors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(colors.separator, lineWidth: 1)
        )
        .shadow(color: colors.separator.opacity(0.4), radius: 8, y: 3)
    }

    private var dateBlock: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(colors.text)
            Text(monthLabel)
                .font(.system(.caption2, design: .serif))
                .foregroundStyle(colors.secondaryText)
        }
        .frame(width: 54)
        .padding(.vertical, 10)
        .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var dayNumber: String {
        let components = Calendar.current.dateComponents([.day], from: entry.date)
        return "\(components.day ?? 1)"
    }

    private var monthLabel: String {
        entry.date.formatted(.dateTime.month(.abbreviated))
    }
}

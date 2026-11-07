import SwiftUI

struct DaySection: View {
    let date: Date
    let entries: [DiaryEntry]
    let colors: ThemeColors
    let onTap: (DiaryEntry) -> Void
    let onDelete: (DiaryEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionTitle)
                .font(.system(.footnote, design: .serif, weight: .semibold))
                .foregroundStyle(colors.secondaryText)
                .padding(.leading, 4)

            VStack(spacing: 10) {
                ForEach(entries) { entry in
                    EntryRow(entry: entry, colors: colors)
                        .onTapGesture {
                            onTap(entry)
                        }
                        .contextMenu {
                            Button {
                                onTap(entry)
                            } label: {
                                Label("查看", systemImage: "book")
                            }
                            Button(role: .destructive) {
                                onDelete(entry)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var sectionTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "今天" }
        if calendar.isDateInYesterday(date) { return "昨天" }
        return date.formatted(.dateTime.month().day().weekday(.wide))
    }
}


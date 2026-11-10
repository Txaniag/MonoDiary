import SwiftUI
import WidgetKit

struct DiaryWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct DiaryWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DiaryWidgetEntry {
        DiaryWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DiaryWidgetEntry) -> Void) {
        let snapshot = context.isPreview ? WidgetSnapshot.placeholder : WidgetSnapshotStore.load()
        completion(DiaryWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DiaryWidgetEntry>) -> Void) {
        let now = Date()
        let entry = DiaryWidgetEntry(date: now, snapshot: WidgetSnapshotStore.load())
        let nextRefresh = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3_600)
        let refreshDate = min(nextRefresh, now.addingTimeInterval(15 * 60))

        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}

struct MonoDiaryWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DiaryWidgetEntry

    private var snapshot: WidgetSnapshot { entry.snapshot }
    private var background: Color {
        Color(hex: snapshot.isDark ? 0x121110 : 0xFAF8F4)
    }
    private var surface: Color {
        Color(hex: snapshot.isDark ? 0x1C1B19 : 0xFFFFFF)
    }
    private var textPrimary: Color {
        Color(hex: snapshot.isDark ? 0xF0EDE6 : 0x1B1917)
    }
    private var textSecondary: Color {
        Color(hex: snapshot.isDark ? 0x9B968C : 0x6E6A63)
    }
    private var accent: Color {
        Color(hex: snapshot.accentHex)
    }

    var body: some View {
        Group {
            if family == .systemMedium {
                mediumWidget
            } else {
                smallWidget
            }
        }
        .containerBackground(for: .widget) {
            background
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("墨记")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(textPrimary)
                Spacer()
                Image(systemName: "book.closed")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(accent)
            }

            Spacer(minLength: 12)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(snapshot.entryCount)")
                    .font(.system(size: 38, weight: .semibold, design: .serif))
                    .foregroundStyle(textPrimary)
                Text("篇")
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundStyle(textSecondary)
            }

            Text(snapshot.latestTitle)
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundStyle(textSecondary)
                .lineLimit(1)
                .padding(.top, 4)
        }
        .padding(16)
    }

    private var mediumWidget: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 0) {
                Text("墨记")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(textPrimary)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(snapshot.entryCount)")
                        .font(.system(size: 42, weight: .semibold, design: .serif))
                        .foregroundStyle(textPrimary)
                    Text("篇日记")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundStyle(textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(textSecondary.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(accent)
                        .frame(width: 7, height: 7)
                    Text("最近写下")
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                        .foregroundStyle(textSecondary)
                }

                Text(snapshot.latestTitle)
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(textPrimary)
                    .lineLimit(2)

                Spacer()

                if let latestDate = snapshot.latestDate {
                    Text(latestDate.formatted(.dateTime.month().day().weekday(.wide)))
                        .font(.system(.caption2, design: .serif))
                        .foregroundStyle(textSecondary)
                } else {
                    Text("写下一篇，留住此刻")
                        .font(.system(.caption2, design: .serif))
                        .foregroundStyle(textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(17)
        .background(surface.opacity(snapshot.isDark ? 0.46 : 0.58), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

@main
struct MonoDiaryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSharedConstants.widgetKind, provider: DiaryWidgetProvider()) { entry in
            MonoDiaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("墨记")
        .description("看看已经写下了多少篇日记，以及最近的一篇。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

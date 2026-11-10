import SwiftData
import SwiftUI

@MainActor
enum WidgetSnapshotCoordinator {
    static func refresh(using context: ModelContext, settings: AppSettings, colorScheme: ColorScheme) {
        let entries = (try? context.fetch(FetchDescriptor<DiaryEntry>())) ?? []
        let snapshot = makeSnapshot(
            entries: entries.sorted { $0.date > $1.date },
            settings: settings,
            colorScheme: colorScheme
        )
        WidgetSnapshotStore.save(snapshot)
    }

    static func makeSnapshot(entries: [DiaryEntry], settings: AppSettings, colorScheme: ColorScheme) -> WidgetSnapshot {
        let isDark = colorScheme == .dark
        let latest = entries.first

        return WidgetSnapshot(
            entryCount: entries.count,
            latestTitle: latest?.displayTitle ?? "今日无字，心亦安然",
            latestDate: latest?.date,
            latestUpdatedAt: latest?.updatedAt,
            isMonochrome: settings.isMonochrome,
            isDark: isDark,
            accentHex: settings.isMonochrome ? (isDark ? 0xFFFFFF : 0x111111) : settings.accent.hex
        )
    }
}

import Foundation
import WidgetKit

enum WidgetSharedConstants {
    static let appGroupID = "group.com.monodiary.app"
    static let widgetKind = "MonoDiaryWidget"
    static let snapshotKey = "widget.snapshot"
}

struct WidgetSnapshot: Codable, Equatable {
    var entryCount: Int
    var latestTitle: String
    var latestDate: Date?
    var isMonochrome: Bool
    var isDark: Bool
    var accentHex: UInt32

    static let placeholder = WidgetSnapshot(
        entryCount: 0,
        latestTitle: "今日无字，心亦安然",
        latestDate: nil,
        isMonochrome: false,
        isDark: false,
        accentHex: 0xC2472E
    )
}

enum WidgetSnapshotStore {
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: WidgetSharedConstants.appGroupID) ?? .standard
    }

    static func load() -> WidgetSnapshot {
        guard
            let data = defaults.data(forKey: WidgetSharedConstants.snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .placeholder
        }
        return snapshot
    }

    static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: WidgetSharedConstants.snapshotKey)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSharedConstants.widgetKind)
    }
}

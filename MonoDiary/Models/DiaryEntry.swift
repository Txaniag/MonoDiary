import Foundation
import SwiftData

@Model
final class DiaryEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var moodRaw: String
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var location: String
    @Relationship(deleteRule: .cascade, inverse: \DiaryPhoto.entry)
    var photos: [DiaryPhoto]

    init(title: String = "", content: String = "", moodRaw: String = Mood.calm.rawValue, date: Date = Date(), location: String = "") {
        self.id = UUID()
        self.title = title
        self.content = content
        self.moodRaw = moodRaw
        self.date = date
        self.createdAt = Date()
        self.updatedAt = Date()
        self.location = location
        self.photos = []
    }

    var mood: Mood {
        get { Mood(rawValue: moodRaw) ?? .calm }
        set { moodRaw = newValue.rawValue }
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var displayTitle: String {
        trimmedTitle.isEmpty ? "无题" : trimmedTitle
    }

    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

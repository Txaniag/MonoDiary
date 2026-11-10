import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var moodRaw: String = Mood.calm.rawValue
    var date: Date = Date()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var location: String = ""
    @Relationship(deleteRule: .cascade, inverse: \DiaryPhoto.entry)
    var photos: [DiaryPhoto]? = []

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

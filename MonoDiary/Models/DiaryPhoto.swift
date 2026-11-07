import Foundation
import SwiftData

@Model
final class DiaryPhoto {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var data: Data
    var sortOrder: Int
    var entry: DiaryEntry?

    init(data: Data, sortOrder: Int) {
        self.id = UUID()
        self.data = data
        self.sortOrder = sortOrder
    }
}

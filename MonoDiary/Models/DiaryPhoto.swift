import Foundation
import SwiftData

@Model
final class DiaryPhoto {
    var id: UUID = UUID()
    @Attribute(.externalStorage) var data: Data = Data()
    var sortOrder: Int = 0
    var entry: DiaryEntry?

    init(data: Data, sortOrder: Int) {
        self.id = UUID()
        self.data = data
        self.sortOrder = sortOrder
    }
}

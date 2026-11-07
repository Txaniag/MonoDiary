import SwiftUI
import SwiftData

@main
struct MonoDiaryApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .modelContainer(for: [DiaryEntry.self, DiaryPhoto.self])
        }
    }
}

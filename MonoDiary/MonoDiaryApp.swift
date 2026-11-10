import SwiftUI
import SwiftData

@main
struct MonoDiaryApp: App {
    @State private var settings = AppSettings()
    @State private var appLock = AppLock()

    private let modelContainer: ModelContainer

    init() {
        modelContainer = Self.makeModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .environment(appLock)
                .modelContainer(modelContainer)
        }
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([DiaryEntry.self, DiaryPhoto.self])

        do {
            let cloudConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            return try ModelContainer(for: schema, configurations: [cloudConfiguration])
        } catch {
            print("CloudKit model container unavailable, falling back to local storage: \(error)")
        }

        do {
            let localConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            return try ModelContainer(for: schema, configurations: [localConfiguration])
        } catch {
            fatalError("Unable to create the SwiftData container: \(error)")
        }
    }
}

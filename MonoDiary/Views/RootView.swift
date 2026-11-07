import SwiftUI

struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        HomeView()
            .tint(settings.colors(for: systemScheme).accent)
            .preferredColorScheme(settings.appearance.colorScheme)
            .saturation(settings.isMonochrome ? 0 : 1)
            .animation(.easeInOut(duration: 0.35), value: settings.isMonochrome)
    }
}

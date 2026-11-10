import SwiftUI

struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppLock.self) private var appLock
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.scenePhase) private var scenePhase

    private var resolvedColorScheme: ColorScheme {
        settings.appearance.resolved(for: systemScheme)
    }

    var body: some View {
        ZStack {
            HomeView()

            if settings.biometricLockEnabled && !appLock.isUnlocked {
                AppLockView(colors: settings.colors(for: resolvedColorScheme))
                    .transition(.opacity)
                    .zIndex(20)
            }
        }
            .tint(settings.colors(for: resolvedColorScheme).accent)
            .preferredColorScheme(settings.appearance.colorScheme)
            .saturation(settings.isMonochrome ? 0 : 1)
            .animation(.easeInOut(duration: 0.35), value: settings.isMonochrome)
            .animation(.easeInOut(duration: 0.2), value: appLock.isUnlocked)
            .task {
                await appLock.authenticateIfNeeded(enabled: settings.biometricLockEnabled)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background {
                    appLock.lock()
                } else if phase == .active {
                    Task {
                        await appLock.authenticateIfNeeded(enabled: settings.biometricLockEnabled)
                    }
                }
            }
            .onChange(of: settings.biometricLockEnabled) { _, enabled in
                if enabled {
                    Task { await appLock.authenticateIfNeeded(enabled: true) }
                } else {
                    appLock.markUnlocked()
                }
            }
    }
}

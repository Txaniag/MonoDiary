import SwiftUI
import Observation

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AccentOption: String, CaseIterable, Identifiable {
    case cinnabar = "cinnabar"
    case indigo = "indigo"
    case pine = "pine"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cinnabar: "朱砂"
        case .indigo: "黛蓝"
        case .pine: "松绿"
        }
    }

    var color: Color {
        switch self {
        case .cinnabar: Color(hex: 0xC2472E)
        case .indigo: Color(hex: 0x3B4A6B)
        case .pine: Color(hex: 0x3D6B54)
        }
    }
}

struct ThemeColors {
    let background: Color
    let surface: Color
    let surfaceSecondary: Color
    let text: Color
    let secondaryText: Color
    let tertiaryText: Color
    let separator: Color
    let accent: Color
}

@Observable
final class AppSettings {
    var isMonochrome = false
    var appearanceRaw = AppearanceMode.system.rawValue
    var accentRaw = AccentOption.cinnabar.rawValue

    init() {
        let defaults = UserDefaults.standard
        isMonochrome = defaults.bool(forKey: Keys.monochrome)
        appearanceRaw = defaults.string(forKey: Keys.appearance) ?? AppearanceMode.system.rawValue
        accentRaw = defaults.string(forKey: Keys.accent) ?? AccentOption.cinnabar.rawValue
    }

    var appearance: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    var accent: AccentOption {
        get { AccentOption(rawValue: accentRaw) ?? .cinnabar }
        set { accentRaw = newValue.rawValue }
    }

    func persist() {
        let defaults = UserDefaults.standard
        defaults.set(isMonochrome, forKey: Keys.monochrome)
        defaults.set(appearanceRaw, forKey: Keys.appearance)
        defaults.set(accentRaw, forKey: Keys.accent)
    }

    func colors(for scheme: ColorScheme? = nil) -> ThemeColors {
        let dark: Bool
        switch appearance {
        case .system:
            dark = scheme == .dark
        case .light:
            dark = false
        case .dark:
            dark = true
        }

        if isMonochrome {
            return ThemeColors(
                background: dark ? Color(hex: 0x0A0A0A) : Color(hex: 0xFFFFFF),
                surface: dark ? Color(hex: 0x161616) : Color(hex: 0xF2F2F2),
                surfaceSecondary: dark ? Color(hex: 0x1E1E1E) : Color(hex: 0xE9E9E9),
                text: dark ? Color(hex: 0xF5F5F5) : Color(hex: 0x111111),
                secondaryText: dark ? Color(hex: 0x8E8E8E) : Color(hex: 0x757575),
                tertiaryText: dark ? Color(hex: 0x5A5A5A) : Color(hex: 0xA8A8A8),
                separator: dark ? Color(hex: 0x2A2A2A) : Color(hex: 0xE5E5E5),
                accent: dark ? Color(hex: 0xFFFFFF) : Color(hex: 0x111111)
            )
        } else {
            return ThemeColors(
                background: dark ? Color(hex: 0x121110) : Color(hex: 0xFAF8F4),
                surface: dark ? Color(hex: 0x1C1B19) : Color(hex: 0xFFFFFF),
                surfaceSecondary: dark ? Color(hex: 0x262422) : Color(hex: 0xF3F0EA),
                text: dark ? Color(hex: 0xF0EDE6) : Color(hex: 0x1B1917),
                secondaryText: dark ? Color(hex: 0x9B968C) : Color(hex: 0x6E6A63),
                tertiaryText: dark ? Color(hex: 0x66615A) : Color(hex: 0xA8A39A),
                separator: dark ? Color(hex: 0x2E2B28) : Color(hex: 0xEAE6DE),
                accent: accent.color
            )
        }
    }

    private enum Keys {
        static let monochrome = "settings.monochrome"
        static let appearance = "settings.appearance"
        static let accent = "settings.accent"
    }
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

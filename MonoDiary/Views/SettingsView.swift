import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let systemColorScheme: ColorScheme
    @Environment(AppLock.self) private var appLock
    @Environment(\.dismiss) private var dismiss
    @State private var changingBiometricLock = false
    @State private var biometricNote: String?

    private var appearance: AppearanceMode { settings.appearance }
    private var accent: AccentOption { settings.accent }
    private var isMonochrome: Bool { settings.isMonochrome }
    private var resolvedColorScheme: ColorScheme {
        appearance.resolved(for: systemColorScheme)
    }

    private var colors: ThemeColors {
        settings.colors(for: resolvedColorScheme)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    appearanceSection
                    monochromeSection
                    accentSection
                    securitySection
                    aboutSection
                }
                .padding(20)
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(colors.secondaryText)
                }
            }
        }
        .presentationBackground(colors.background)
        .preferredColorScheme(resolvedColorScheme)
        .environment(\.colorScheme, resolvedColorScheme)
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("外观")
            HStack(spacing: 8) {
                ForEach(AppearanceMode.allCases) { mode in
                    Button {
                        settings.appearance = mode
                        settings.persist()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: icon(for: mode))
                                .font(.system(size: 16, weight: .medium))
                            Text(mode.title)
                                .font(.system(.caption, design: .serif, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(appearance == mode ? colors.text : colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(appearance == mode ? colors.surface : colors.secondaryText)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    private var monochromeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("黑白模式")
            HStack(spacing: 14) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(colors.accent)
                    .frame(width: 40, height: 40)
                    .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("黑白 UI")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundStyle(colors.text)
                    Text("将整个界面还原为纯粹的黑与白。")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { isMonochrome },
                    set: { newValue in
                        settings.isMonochrome = newValue
                        settings.persist()
                    }
                ))
                .labelsHidden()
                .tint(colors.text)
            }
            .padding(16)
            .background(colors.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(colors.separator, lineWidth: 1)
            )
        }
    }

    private var accentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("主题色")
            HStack(spacing: 12) {
                ForEach(AccentOption.allCases) { option in
                    Button {
                        settings.accent = option
                        settings.persist()
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(option.color)
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Circle().stroke(colors.separator, lineWidth: 1)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                        .opacity(accent == option ? 1 : 0)
                                )
                            Text(option.title)
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(accent == option ? colors.text : colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(accent == option ? colors.surfaceSecondary : .clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            if isMonochrome {
                Text("黑白模式下主题色会被隐藏。")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(colors.tertiaryText)
            }
        }
    }

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("同步与安全")

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(colors.accent)
                        .frame(width: 40, height: 40)
                        .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud 同步")
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundStyle(colors.text)
                        Text("日记会通过你的 iCloud 账户自动同步。")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(colors.secondaryText)
                    }

                    Spacer()

                    Text("自动")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(16)

                Divider()
                    .overlay(colors.separator)
                    .padding(.leading, 70)

                HStack(spacing: 14) {
                    Group {
                        if changingBiometricLock {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "faceid")
                                .font(.system(size: 20, weight: .light))
                        }
                    }
                    .foregroundStyle(colors.accent)
                    .frame(width: 40, height: 40)
                    .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("应用锁")
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundStyle(colors.text)
                        Text("使用面容、触控 ID 或设备密码解锁。")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(colors.secondaryText)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { settings.biometricLockEnabled },
                        set: { enabled in
                            Task { await updateBiometricLock(enabled) }
                        }
                    ))
                    .labelsHidden()
                    .tint(colors.text)
                    .disabled(changingBiometricLock)
                }
                .padding(16)
            }
            .background(colors.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(colors.separator, lineWidth: 1)
            )

            if let biometricNote {
                Text(biometricNote)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(colors.tertiaryText)
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("关于")
            VStack(spacing: 0) {
                aboutRow(title: "版本", value: "1.0")
                Divider()
                    .overlay(colors.separator)
                    .padding(.leading, 16)
                aboutRow(title: "设计", value: "黑白之间，记录日常")
            }
            .padding(.horizontal, 16)
            .background(colors.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(colors.separator, lineWidth: 1)
            )
        }
    }

    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(colors.text)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(colors.secondaryText)
        }
        .padding(.vertical, 14)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(.footnote, design: .serif, weight: .semibold))
            .foregroundStyle(colors.secondaryText)
            .textCase(.uppercase)
            .tracking(1)
    }

    private func icon(for mode: AppearanceMode) -> String {
        switch mode {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    @MainActor
    private func updateBiometricLock(_ enabled: Bool) async {
        guard enabled else {
            settings.biometricLockEnabled = false
            settings.persist()
            appLock.markUnlocked()
            biometricNote = nil
            return
        }

        let availability = AppLock.availability()
        guard availability.isAvailable else {
            settings.biometricLockEnabled = false
            settings.persist()
            biometricNote = availability.message
            return
        }

        changingBiometricLock = true
        let unlocked = await appLock.authenticate()
        changingBiometricLock = false

        if unlocked {
            settings.biometricLockEnabled = true
            settings.persist()
            biometricNote = "已启用，下次回到墨记时需要验证身份。"
            Haptics.success()
        } else {
            settings.biometricLockEnabled = false
            settings.persist()
            biometricNote = appLock.errorMessage ?? "未能启用应用锁。"
        }
    }
}

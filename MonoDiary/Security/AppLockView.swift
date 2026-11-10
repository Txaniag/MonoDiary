import SwiftUI

struct AppLockView: View {
    let colors: ThemeColors
    @Environment(AppLock.self) private var appLock

    private var authenticationTitle: String {
        AppLock.availability().title
    }

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(colors.accent)
                    .frame(width: 64, height: 64)
                    .background(colors.surfaceSecondary, in: Circle())

                VStack(spacing: 7) {
                    Text("墨记已锁定")
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .foregroundStyle(colors.text)
                    Text("你的日记只为你打开")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(colors.secondaryText)
                }

                Button {
                    Task { _ = await appLock.authenticate() }
                } label: {
                    HStack(spacing: 8) {
                        if appLock.isAuthenticating {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "faceid")
                        }
                        Text(appLock.isAuthenticating ? "正在验证" : "使用\(authenticationTitle)解锁")
                    }
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(colors.surface)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(colors.text, in: Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(appLock.isAuthenticating)

                if let message = appLock.errorMessage {
                    Text(message)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
    }
}

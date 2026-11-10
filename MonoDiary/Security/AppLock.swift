import LocalAuthentication
import Observation

struct BiometricAvailability {
    let isAvailable: Bool
    let title: String
    let message: String?
}

@Observable
final class AppLock {
    private(set) var isUnlocked = false
    private(set) var isAuthenticating = false
    var errorMessage: String?

    @MainActor
    func markUnlocked() {
        isUnlocked = true
        isAuthenticating = false
        errorMessage = nil
    }

    @MainActor
    func lock() {
        isUnlocked = false
        isAuthenticating = false
        errorMessage = nil
    }

    @MainActor
    func authenticateIfNeeded(enabled: Bool) async {
        guard enabled else {
            markUnlocked()
            return
        }
        guard !isUnlocked else { return }
        _ = await authenticate()
    }

    @MainActor
    @discardableResult
    func authenticate() async -> Bool {
        guard !isAuthenticating else { return false }

        let availability = Self.availability()
        guard availability.isAvailable else {
            isUnlocked = false
            errorMessage = availability.message
            return false
        }

        isAuthenticating = true
        errorMessage = nil

        let context = LAContext()
        context.localizedCancelTitle = "取消"

        let result: Result<Bool, Error> = await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "解锁墨记，查看你的日记"
            ) { success, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success(success))
                }
            }
        }

        isAuthenticating = false

        switch result {
        case .success(true):
            isUnlocked = true
            errorMessage = nil
            return true
        case .success(false):
            isUnlocked = false
            errorMessage = "未能验证身份，请重试。"
            return false
        case .failure(let error):
            isUnlocked = false
            if let laError = error as? LAError,
               [.userCancel, .appCancel, .systemCancel].contains(laError.code) {
                errorMessage = nil
            } else {
                errorMessage = "身份验证未完成，请重试。"
            }
            return false
        }
    }

    static func availability() -> BiometricAvailability {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthentication, withError: &error)

        let title: String
        if context.biometryType == .faceID {
            title = "面容 ID"
        } else if context.biometryType == .touchID {
            title = "触控 ID"
        } else {
            title = "设备密码"
        }

        return BiometricAvailability(
            isAvailable: available,
            title: title,
            message: available ? nil : "请先在系统设置中启用面容、触控 ID 或设备密码。"
        )
    }
}

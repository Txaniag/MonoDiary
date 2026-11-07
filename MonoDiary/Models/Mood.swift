import SwiftUI

enum Mood: String, CaseIterable, Identifiable {
    case calm = "平静"
    case happy = "开心"
    case sad = "难过"
    case miss = "思念"
    case tired = "疲惫"
    case excited = "激动"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .calm: "wind"
        case .happy: "sun.max"
        case .sad: "cloud.rain"
        case .miss: "moon.stars"
        case .tired: "zzz"
        case .excited: "sparkles"
        }
    }
}

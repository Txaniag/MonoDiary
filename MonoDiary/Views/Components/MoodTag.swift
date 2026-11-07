import SwiftUI

struct MoodTag: View {
    let mood: Mood
    let colors: ThemeColors

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: mood.symbol)
                .font(.system(size: 9, weight: .semibold))
            Text(mood.rawValue)
                .font(.system(.caption2, design: .serif, weight: .medium))
        }
        .foregroundStyle(colors.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colors.accent.opacity(0.1), in: Capsule())
    }
}

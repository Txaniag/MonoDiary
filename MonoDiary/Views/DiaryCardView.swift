import SwiftUI

struct DiaryCardView: View {
    let entry: DiaryEntry
    let style: CardStyle
    let colors: ThemeColors

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                Spacer(minLength: 0)
                contentBlock
                Spacer(minLength: 0)
                footer
            }
            .padding(40)
        }
        .frame(width: 360, height: 480)
    }

    private var foreground: Color {
        style == .midnight ? colors.surface : colors.text
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .minimal:
            colors.surface
                .overlay(Rectangle().stroke(colors.separator, lineWidth: 1))
        case .midnight:
            colors.text
                .overlay(
                    Circle()
                        .fill(colors.surface.opacity(0.08))
                        .frame(width: 320, height: 320)
                        .offset(x: 130, y: -190)
                )
        case .paper:
            colors.background
                .overlay(alignment: .bottomTrailing) {
                    Text("记")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(colors.surface)
                        .padding(6)
                        .background(colors.accent, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .padding(28)
                }
                .overlay(Rectangle().stroke(colors.separator, lineWidth: 1))
        }
    }

    private var header: some View {
        HStack {
            Text(entry.date.formatted(.dateTime.month().day().year()))
                .font(.system(.footnote, design: .serif))
                .tracking(2)
            Spacer()
            Image(systemName: entry.mood.symbol)
                .font(.system(size: 13))
        }
        .foregroundStyle(foreground)
        .opacity(0.7)
    }

    private var contentBlock: some View {
        VStack(spacing: 18) {
            Text("“")
                .font(.system(size: 56, weight: .regular, design: .serif))
                .opacity(0.35)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, -6)

            Text(entry.displayTitle)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .lineLimit(2)
                .minimumScaleFactor(0.6)

            if !excerpt.isEmpty {
                Text(excerpt)
                    .font(.system(size: 15, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .opacity(0.8)
                    .lineLimit(6)
            }
        }
        .foregroundStyle(foreground)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(foreground.opacity(0.6))
                .frame(width: 18, height: 1)
            Text("墨记")
                .font(.system(size: 11, weight: .medium, design: .serif))
                .tracking(4)
            Rectangle()
                .fill(foreground.opacity(0.6))
                .frame(width: 18, height: 1)
        }
        .opacity(0.7)
        .foregroundStyle(foreground)
    }

    private var excerpt: String {
        let text = entry.trimmedContent
        let maxLength = 110
        if text.count <= maxLength { return text }
        let end = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..end]) + "……"
    }
}


import SwiftUI
import UIKit

struct CardGeneratorView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.dismiss) private var dismiss

    let entry: DiaryEntry

    @State private var style: CardStyle = .minimal
    @State private var savedToast = false

    private var colors: ThemeColors { settings.colors(for: systemScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    cardPreview
                    stylePicker
                    actions
                }
                .padding(20)
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("日记成图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .overlay(alignment: .bottom) {
                if savedToast {
                    Text("已保存到相册")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(colors.surface)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(colors.text, in: Capsule())
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
        }
    }

    private var cardPreview: some View {
        DiaryCardView(entry: entry, style: style, colors: colors)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(colors.separator, lineWidth: 1)
            )
            .shadow(color: colors.separator.opacity(0.5), radius: 18, y: 8)
            .padding(.top, 8)
    }

    private var stylePicker: some View {
        HStack(spacing: 8) {
            ForEach(CardStyle.allCases) { option in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        style = option
                    }
                } label: {
                    Text(option.rawValue)
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(style == option ? colors.text : colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundStyle(style == option ? colors.surface : colors.secondaryText)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                saveToPhotos()
            } label: {
                Label("保存到相册", systemImage: "arrow.down.to.line")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(colors.text, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(colors.surface)
            }
            .buttonStyle(ScaleButtonStyle())

            if let image = renderedImage {
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview("墨记 · \(entry.displayTitle)", image: Image(uiImage: image))
                ) {
                    Label("分享给朋友", systemImage: "square.and.arrow.up")
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(colors.text)
                }
            }
        }
    }

    private var renderedImage: UIImage? {
        let renderer = ImageRenderer(
            content: DiaryCardView(entry: entry, style: style, colors: colors)
        )
        renderer.scale = 3
        return renderer.uiImage
    }

    private func saveToPhotos() {
        guard let image = renderedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        Haptics.success()
        withAnimation(.easeOut(duration: 0.25)) {
            savedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.25)) {
                savedToast = false
            }
        }
    }
}

enum CardStyle: String, CaseIterable, Identifiable {
    case minimal = "留白"
    case midnight = "墨夜"
    case paper = "信纸"

    var id: String { rawValue }
}

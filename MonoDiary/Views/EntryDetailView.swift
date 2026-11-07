import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var systemScheme

    let entry: DiaryEntry
    let onDelete: () -> Void

    @State private var showingEditor = false
    @State private var showingCard = false

    private var colors: ThemeColors { settings.colors(for: systemScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 10) {
                        MoodTag(mood: entry.mood, colors: colors)
                        Text(entry.date.formatted(.dateTime.year().month().day().weekday(.wide)))
                            .font(.system(.footnote, design: .serif))
                            .foregroundStyle(colors.secondaryText)
                        Spacer()
                    }

                    Text(entry.displayTitle)
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                        .foregroundStyle(colors.text)
                        .lineSpacing(4)

                    if !entry.trimmedContent.isEmpty {
                        Text(entry.trimmedContent)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(colors.text)
                            .lineSpacing(8)
                    }

                    Divider()
                        .overlay(colors.separator)

                    HStack(spacing: 10) {
                        Button {
                            showingCard = true
                        } label: {
                            Label("生成图片", systemImage: "photo.on.rectangle.angled")
                                .font(.system(.subheadline, design: .serif, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(colors.text, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(colors.surface)
                        }
                        .buttonStyle(ScaleButtonStyle())

                        Button {
                            showingEditor = true
                        } label: {
                            Label("编辑", systemImage: "pencil")
                                .font(.system(.subheadline, design: .serif, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(colors.text)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(24)
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(colors.secondaryText)
                }
            }
            .fullScreenCover(isPresented: $showingEditor) {
                EditorView(entry: entry)
                    .environment(settings)
            }
            .sheet(isPresented: $showingCard) {
                CardGeneratorView(entry: entry)
                    .environment(settings)
            }
        }
    }
}

import SwiftUI
import UIKit

struct EntryDetailView: View {
    let settings: AppSettings
    @Environment(\.colorScheme) private var systemScheme

    let entry: DiaryEntry
    let onDelete: () -> Void

    @State private var showingEditor = false
    @State private var showingCard = false
    @State private var viewingPhoto: DiaryPhoto?

    private var resolvedColorScheme: ColorScheme {
        settings.appearance.resolved(for: systemScheme)
    }

    private var colors: ThemeColors { settings.colors(for: resolvedColorScheme) }

    private var sortedPhotos: [DiaryPhoto] {
        entry.photos.sorted { $0.sortOrder < $1.sortOrder }
    }

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

                    if !entry.location.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text(entry.location)
                                .font(.system(.footnote, design: .serif, weight: .medium))
                                .foregroundStyle(colors.accent)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(colors.accent.opacity(0.1), in: Capsule())
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

                    if !sortedPhotos.isEmpty {
                        photoGallery
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
                EditorView(settings: settings, entry: entry)
                    .preferredColorScheme(resolvedColorScheme)
                    .environment(\.colorScheme, resolvedColorScheme)
            }
            .sheet(isPresented: $showingCard) {
                CardGeneratorView(settings: settings, entry: entry)
                    .preferredColorScheme(resolvedColorScheme)
                    .environment(\.colorScheme, resolvedColorScheme)
                    .presentationBackground(colors.background)
            }
            .fullScreenCover(item: $viewingPhoto) { photo in
                PhotoViewer(photo: photo, colors: colors)
                    .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(resolvedColorScheme)
        .environment(\.colorScheme, resolvedColorScheme)
    }

    private var photoGallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(sortedPhotos) { photo in
                    if let uiImage = UIImage(data: photo.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(colors.separator, lineWidth: 1)
                            )
                            .onTapGesture {
                                viewingPhoto = photo
                            }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct PhotoViewer: View {
    let photo: DiaryPhoto
    let colors: ThemeColors
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let uiImage = UIImage(data: photo.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(16)
                }
                Spacer()
            }
        }
        .statusBarHidden(true)
    }
}


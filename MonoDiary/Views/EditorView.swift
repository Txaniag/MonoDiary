import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct PhotoItem: Identifiable {
    let id = UUID()
    let data: Data
}

struct EditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let settings: AppSettings
    @Environment(\.colorScheme) private var systemScheme

    let entry: DiaryEntry?

    @State private var title = ""
    @State private var content = ""
    @State private var mood: Mood = .calm
    @State private var date = Date()
    @State private var showingDatePicker = false
    @State private var photoItems: [PhotoItem] = []
    @State private var showingCamera = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var locationManager = LocationManager()

    private var resolvedColorScheme: ColorScheme {
        settings.appearance.resolved(for: systemScheme)
    }

    private var colors: ThemeColors { settings.colors(for: resolvedColorScheme) }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    topRow
                    moodSelector
                    titleField
                    contentField
                    photoSection
                }
                .padding(20)
            }
            .background(colors.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(entry == nil ? "写日记" : "编辑日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(colors.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(canSave ? colors.accent : colors.tertiaryText)
                        .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                VStack(spacing: 12) {
                    DatePicker("选择日期", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(20)
                    Button("完成") { showingDatePicker = false }
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundStyle(colors.accent)
                        .padding(.bottom, 16)
                }
                .background(colors.background.ignoresSafeArea())
                .preferredColorScheme(resolvedColorScheme)
                .environment(\.colorScheme, resolvedColorScheme)
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker { image in
                    if let data = ImageCompressor.compress(image) {
                        photoItems.append(PhotoItem(data: data))
                    }
                }
            }
            .onAppear(perform: load)
        }
        .preferredColorScheme(resolvedColorScheme)
        .environment(\.colorScheme, resolvedColorScheme)
    }

    private var topRow: some View {
        HStack(spacing: 8) {
            dateButton
            locationTag
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var locationTag: some View {
        if locationManager.isLocating {
            HStack(spacing: 6) {
                ProgressView()
                    .controlSize(.mini)
                Text("正在获取位置")
                    .font(.system(.subheadline, design: .serif))
            }
            .foregroundStyle(colors.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(colors.surfaceSecondary, in: Capsule())
        } else if let place = locationManager.currentPlace, !place.isEmpty {
            HStack(spacing: 5) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10, weight: .semibold))
                Text(place)
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(colors.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(colors.accent.opacity(0.1), in: Capsule())
        }
    }

    private var dateButton: some View {
        Button {
            showingDatePicker = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .medium))
                Text(date.formatted(.dateTime.year().month().day().weekday(.wide)))
                    .font(.system(.subheadline, design: .serif, weight: .medium))
            }
            .foregroundStyle(colors.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(colors.surfaceSecondary, in: Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var moodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Mood.allCases) { option in
                    Button {
                        mood = option
                        Haptics.light()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: option.symbol)
                                .font(.system(size: 11, weight: .semibold))
                            Text(option.rawValue)
                                .font(.system(.subheadline, design: .serif, weight: .medium))
                        }
                        .foregroundStyle(mood == option ? colors.surface : colors.secondaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(mood == option ? colors.text : colors.surfaceSecondary, in: Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    private var titleField: some View {
        TextField("标题", text: $title)
            .font(.system(size: 30, weight: .semibold, design: .serif))
            .foregroundStyle(colors.text)
            .textFieldStyle(.plain)
            .padding(.top, 8)
    }

    private var contentField: some View {
        TextEditor(text: $content)
            .font(.system(.body, design: .serif))
            .foregroundStyle(colors.text)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 320)
            .overlay(alignment: .topLeading) {
                if content.isEmpty {
                    Text("写下此刻的心情、天气，或者任何你想记住的事……")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(colors.tertiaryText)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("图片")
                .font(.system(.footnote, design: .serif, weight: .semibold))
                .foregroundStyle(colors.secondaryText)
                .textCase(.uppercase)
                .tracking(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(photoItems) { item in
                        photoThumbnail(item)
                    }
                    addPhotoButtons
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.top, 8)
    }

    private func photoThumbnail(_ item: PhotoItem) -> some View {
        Group {
            if let uiImage = UIImage(data: item.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation(.easeOut(duration: 0.15)) {
                                photoItems.removeAll { $0.id == item.id }
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(colors.text.opacity(0.7), colors.surface)
                        }
                        .padding(4)
                    }
            }
        }
    }

    private var addPhotoButtons: some View {
        HStack(spacing: 10) {
            Button {
                showingCamera = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "camera")
                        .font(.system(size: 18, weight: .medium))
                    Text("拍照")
                        .font(.system(.caption2, design: .serif))
                }
                .foregroundStyle(colors.secondaryText)
                .frame(width: 84, height: 84)
                .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(colors.separator, style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
            }
            .buttonStyle(ScaleButtonStyle())

            PhotosPicker(selection: $selectedPhotos, matching: .images) {
                VStack(spacing: 4) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 18, weight: .medium))
                    Text("相册")
                        .font(.system(.caption2, design: .serif))
                }
                .foregroundStyle(colors.secondaryText)
                .frame(width: 84, height: 84)
                .background(colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(colors.separator, style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
            }
            .onChange(of: selectedPhotos) { _, items in
                Task {
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data),
                           let compressed = ImageCompressor.compress(image) {
                            photoItems.append(PhotoItem(data: compressed))
                        }
                    }
                    selectedPhotos = []
                }
            }
        }
    }

    private func load() {
        guard let entry else {
            locationManager.requestLocation()
            return
        }
        title = entry.title
        content = entry.content
        mood = entry.mood
        date = entry.date
        if entry.location.isEmpty {
            locationManager.requestLocation()
        } else {
            locationManager.currentPlace = entry.location
        }
        photoItems = (entry.photos ?? [])
            .sorted { $0.sortOrder < $1.sortOrder }
            .compactMap { PhotoItem(data: $0.data) }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty || !trimmedContent.isEmpty else { return }

        if let entry {
            entry.title = trimmedTitle
            entry.content = trimmedContent
            entry.mood = mood
            entry.date = date
            entry.updatedAt = Date()
            entry.location = locationManager.currentPlace ?? entry.location
            updatePhotos(for: entry)
        } else {
            let newEntry = DiaryEntry(title: trimmedTitle, content: trimmedContent, moodRaw: mood.rawValue, date: date)
            newEntry.location = locationManager.currentPlace ?? ""
            modelContext.insert(newEntry)
            updatePhotos(for: newEntry)
        }
        try? modelContext.save()
        Haptics.success()
        dismiss()
    }

    private func updatePhotos(for entry: DiaryEntry) {
        let oldPhotos = Array(entry.photos ?? [])
        for photo in oldPhotos {
            modelContext.delete(photo)
        }
        entry.photos = []
        for (index, item) in photoItems.enumerated() {
            let photo = DiaryPhoto(data: item.data, sortOrder: index)
            photo.entry = entry
            modelContext.insert(photo)
        }
    }
}

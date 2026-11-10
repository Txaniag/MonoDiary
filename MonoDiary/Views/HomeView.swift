import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]
    @State private var searchText = ""
    @State private var showingEditor = false
    @State private var showingSettings = false
    @State private var selectedEntry: DiaryEntry?

    private var resolvedColorScheme: ColorScheme {
        settings.appearance.resolved(for: systemScheme)
    }

    private var colors: ThemeColors { settings.colors(for: resolvedColorScheme) }

    private var widgetSnapshot: WidgetSnapshot {
        let isDark = resolvedColorScheme == .dark
        return WidgetSnapshot(
            entryCount: entries.count,
            latestTitle: entries.first?.displayTitle ?? "今日无字，心亦安然",
            latestDate: entries.first?.date,
            isMonochrome: settings.isMonochrome,
            isDark: isDark,
            accentHex: settings.isMonochrome ? (isDark ? 0xFFFFFF : 0x111111) : settings.accent.hex
        )
    }

    private var filteredEntries: [DiaryEntry] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return entries }
        return entries.filter {
            $0.displayTitle.localizedStandardContains(trimmed) ||
            $0.content.localizedStandardContains(trimmed)
        }
    }

    private var grouped: [DayGroup] {
        let dict = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        return dict.map { DayGroup(day: $0.key, entries: $0.value) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    header
                    if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        ForEach(grouped) { group in
                            DaySection(
                                date: group.day,
                                entries: group.entries,
                                colors: colors,
                                onTap: { entry in
                                    selectedEntry = entry
                                },
                                onDelete: { entry in
                                    delete(entry)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(colors.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(colors.text)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(colors.accent)
                }
            }
            .searchable(text: $searchText, prompt: "搜索日记")
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings, systemColorScheme: resolvedColorScheme)
                .preferredColorScheme(resolvedColorScheme)
                .environment(\.colorScheme, resolvedColorScheme)
                .presentationBackground(colors.background)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(
                settings: settings,
                entry: entry,
                onDelete: {
                    selectedEntry = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        delete(entry)
                    }
                }
            )
            .preferredColorScheme(resolvedColorScheme)
            .environment(\.colorScheme, resolvedColorScheme)
            .presentationBackground(colors.background)
        }
        .fullScreenCover(isPresented: $showingEditor) {
            EditorView(settings: settings, entry: nil)
                .preferredColorScheme(resolvedColorScheme)
                .environment(\.colorScheme, resolvedColorScheme)
        }
        .onAppear {
            WidgetSnapshotStore.save(widgetSnapshot)
        }
        .onChange(of: widgetSnapshot) { _, snapshot in
            WidgetSnapshotStore.save(snapshot)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .background, settings.biometricLockEnabled else { return }
            showingSettings = false
            selectedEntry = nil
            showingEditor = false
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("墨记")
                .font(.system(size: 36, weight: .semibold, design: .serif))
                .foregroundStyle(colors.text)
            Text("\(todayLine) · 已写 \(entries.count) 篇")
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(colors.secondaryText)
        }
        .padding(.top, 12)
    }

    private var todayLine: String {
        Date().formatted(.dateTime.month().day().weekday(.wide))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(colors.tertiaryText)
            Text("今日无字，心亦安然")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(colors.text)
            Text("把此刻的心情写下来，它会成为未来的礼物。")
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(colors.secondaryText)
                .multilineTextAlignment(.center)
            Button {
                showingEditor = true
            } label: {
                Text("写第一篇日记")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(colors.surface)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(colors.text, in: Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 32)
    }

    private func delete(_ entry: DiaryEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        Haptics.medium()
    }
}

struct DayGroup: Identifiable {
    let day: Date
    let entries: [DiaryEntry]
    var id: Date { day }
}

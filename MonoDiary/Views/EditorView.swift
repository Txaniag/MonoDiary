import SwiftUI
import SwiftData

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

    private var colors: ThemeColors { settings.colors(for: systemScheme) }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    dateButton
                    moodSelector
                    titleField
                    contentField
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
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
            }
            .onAppear(perform: load)
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

    private func load() {
        guard let entry else { return }
        title = entry.title
        content = entry.content
        mood = entry.mood
        date = entry.date
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
        } else {
            let newEntry = DiaryEntry(title: trimmedTitle, content: trimmedContent, moodRaw: mood.rawValue, date: date)
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
        Haptics.success()
        dismiss()
    }
}

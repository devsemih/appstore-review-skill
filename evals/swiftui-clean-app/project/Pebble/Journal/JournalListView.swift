import SwiftUI

struct JournalListView: View {
    @Environment(StoreManager.self) private var store
    @State private var entries: [JournalEntry] = []
    @State private var editing: JournalEntry?
    @State private var showPaywall = false

    private let freeEntryLimit = 30

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    Button { editing = entry } label: {
                        HStack {
                            Text(entry.mood.emoji)
                            VStack(alignment: .leading) {
                                Text(entry.title).font(.headline)
                                Text(entry.date, style: .date).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { entries.remove(atOffsets: $0) }
            }
            .overlay {
                if entries.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "square.and.pencil",
                                           description: Text("Tap + to write your first entry."))
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if store.hasPlus || entries.count < freeEntryLimit {
                            editing = JournalEntry(title: "", body: "", mood: .good)
                        } else {
                            showPaywall = true
                        }
                    } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }
                }
            }
            .sheet(item: $editing) { entry in
                JournalEditorView(entry: entry) { saved in
                    if let index = entries.firstIndex(where: { $0.id == saved.id }) {
                        entries[index] = saved
                    } else {
                        entries.insert(saved, at: 0)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }
}

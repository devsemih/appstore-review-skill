import PhotosUI
import SwiftUI

struct JournalEditorView: View {
    @State var entry: JournalEntry
    var onSave: (JournalEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $entry.title)
                Picker("Mood", selection: $entry.mood) {
                    ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                        Text(mood.emoji).tag(mood)
                    }
                }
                .pickerStyle(.segmented)
                TextEditor(text: $entry.body)
                    .frame(minHeight: 200)
                // PhotosPicker runs out of process and needs no photo library permission.
                PhotosPicker("Attach a photo", selection: $photoItem, matching: .images)
                if let data = entry.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFit()
                }
            }
            .onChange(of: photoItem) { _, item in
                Task { entry.photoData = try? await item?.loadTransferable(type: Data.self) }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(entry); dismiss() }
                        .disabled(entry.title.isEmpty)
                }
            }
        }
    }
}

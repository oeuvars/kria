import SwiftUI

struct NoteDetailView: View {
    let note: Note
    let apiService: APIService
    let onNoteUpdated: () -> Void
    let onNoteDeleted: () -> Void
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isSaving = false
    @State private var showingDeleteAlert = false
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    init(note: Note, apiService: APIService, onNoteUpdated: @escaping () -> Void, onNoteDeleted: @escaping () -> Void) {
        self.note = note
        self.apiService = apiService
        self.onNoteUpdated = onNoteUpdated
        self.onNoteDeleted = onNoteDeleted
        self._editedTitle = State(initialValue: note.title)
        self._editedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isEditing {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        TextField("Note title", text: $editedTitle)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Content")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.textBackgroundColor))
                                .stroke(Color(.separatorColor), lineWidth: 1)
                            
                            TextEditor(text: $editedContent)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                                .font(.body)
                                .scrollContentBackground(.hidden)
                        }
                        .frame(minHeight: 300)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(note.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Created")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text(note.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Updated")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text(note.updatedAt, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    Text(note.content.isEmpty ? "No content" : note.content)
                        .font(.body)
                        .foregroundColor(note.content.isEmpty ? .secondary : .primary)
                        .lineSpacing(4)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    if isEditing {
                        Button("Cancel") {
                            editedTitle = note.title
                            editedContent = note.content
                            isEditing = false
                        }
                        
                        Button("Save") {
                            saveChanges()
                        }
                        .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteNote()
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        isSaving = true
        Task {
            do {
                _ = try await apiService.updateNote(
                    id: note.id,
                    title: trimmedTitle != note.title ? trimmedTitle : nil,
                    content: editedContent != note.content ? editedContent : nil
                )
                await MainActor.run {
                    isEditing = false
                    isSaving = false
                    onNoteUpdated()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save changes: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
    
    private func deleteNote() {
        Task {
            do {
                try await apiService.deleteNote(id: note.id)
                await MainActor.run {
                    onNoteDeleted()
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete note: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NoteDetailView(
                note: Note(
                    id: "1",
                    title: "Sample Note",
                    content: "This is a sample note content.",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                apiService: APIService(),
                onNoteUpdated: {},
                onNoteDeleted: {}
            )
        }
    }
}
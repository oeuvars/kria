import SwiftUI

struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    let apiService: APIService
    let onNoteSaved: () -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    TextField("Enter note title", text: $title)
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
                        
                        if content.isEmpty {
                            Text("Start writing your note...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .font(.body)
                        }
                        
                        TextEditor(text: $content)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                    }
                    .frame(minHeight: 200)
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func saveNote() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSaving = true
        Task {
            do {
                _ = try await apiService.createNote(title: title.trimmingCharacters(in: .whitespacesAndNewlines), content: content)
                await MainActor.run {
                    onNoteSaved()
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save note: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView(apiService: APIService(), onNoteSaved: {})
    }
}
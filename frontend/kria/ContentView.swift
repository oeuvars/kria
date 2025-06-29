//
//  ContentView.swift
//  kria
//
//  Created by Abhipsa Das on 30/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading notes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if notes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.secondary)
                        VStack(spacing: 8) {
                            Text("No Notes")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("Create your first note to get started")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink(destination: NoteDetailView(note: note, apiService: apiService, onNoteUpdated: loadNotes, onNoteDeleted: loadNotes)) {
                                NoteRowView(note: note)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.controlBackgroundColor))
                                    .padding(.vertical, 2)
                            )
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(apiService: apiService, onNoteSaved: loadNotes)
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear {
                loadNotes()
            }
        }
    }
    
    private func loadNotes() {
        isLoading = true
        Task {
            do {
                let fetchedNotes = try await apiService.fetchNotes()
                await MainActor.run {
                    self.notes = fetchedNotes
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load notes: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            Task {
                do {
                    try await apiService.deleteNote(id: note.id)
                    await MainActor.run {
                        notes.remove(at: index)
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to delete note: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Spacer()
                Text(note.updatedAt, style: .relative)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}

import Foundation

class APIService: ObservableObject {
    private let baseURL = "http://localhost:8080/api/v1"
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init() {
        // Create a custom date formatter that handles the backend's format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        encoder.dateEncodingStrategy = .formatted(formatter)
    }
    
    func fetchNotes() async throws -> [Note] {
        guard let url = URL(string: "\(baseURL)/notes") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(NotesResponse.self, from: data)
        return response.notes
    }
    
    func createNote(title: String, content: String) async throws -> Note {
        guard let url = URL(string: "\(baseURL)/notes") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let createRequest = CreateNoteRequest(title: title, content: content)
        request.httpBody = try encoder.encode(createRequest)
        
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Note.self, from: data)
    }
    
    func updateNote(id: String, title: String?, content: String?) async throws -> Note {
        guard let url = URL(string: "\(baseURL)/notes/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateRequest = UpdateNoteRequest(title: title, content: content)
        request.httpBody = try encoder.encode(updateRequest)
        
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Note.self, from: data)
    }
    
    func deleteNote(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/notes/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        _ = try await session.data(for: request)
    }
}
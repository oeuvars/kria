import Foundation

struct Note: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CreateNoteRequest: Codable {
    let title: String
    let content: String
}

struct UpdateNoteRequest: Codable {
    let title: String?
    let content: String?
}

struct NotesResponse: Codable {
    let notes: [Note]
}

struct ErrorResponse: Codable {
    let error: String
}
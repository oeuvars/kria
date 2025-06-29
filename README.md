# Kria Notes App

A typesafe notes application built with Go backend and SwiftUI frontend in a monorepo structure.

## Architecture

- **Backend**: Go with Gin framework, SQLite database
- **Frontend**: SwiftUI iOS app
- **Type Safety**: OpenAPI spec ensures consistent types between backend and frontend
- **Monorepo**: Single repository containing both backend and frontend code

## Project Structure

```
kria/
├── backend/           # Go backend API
│   ├── main.go       # API server with Gin
│   ├── models.go     # Data models
│   └── database.go   # SQLite database operations
├── frontend/         # SwiftUI iOS app
│   └── NotesApp/     # Xcode project
├── shared/           # Shared specifications
│   └── openapi.yaml  # API specification
├── go.mod           # Go dependencies
├── Makefile         # Build scripts
└── README.md        # This file
```

## Features

- **CRUD Operations**: Create, read, update, delete notes
- **Type Safety**: Shared data models between backend and frontend
- **Real-time Updates**: SwiftUI reactive UI updates
- **Persistent Storage**: SQLite database for notes storage
- **REST API**: Clean REST endpoints for all operations

## Getting Started

### Prerequisites

- Go 1.21+
- Xcode 15+ (for iOS app)
- iOS Simulator or device

### Backend Setup

1. Install dependencies:
   ```bash
   make install-deps
   ```

2. Run the backend server:
   ```bash
   make run-backend
   ```

   The API will be available at `http://localhost:8080`

### Frontend Setup

1. Open the Xcode project:
   ```bash
   open frontend/NotesApp.xcodeproj
   ```

2. Build and run the iOS app in Xcode
3. Make sure the backend is running on localhost:8080

### Development

- **Backend**: The Go server includes CORS headers for development
- **Frontend**: The iOS app connects to localhost:8080 by default
- **Database**: SQLite database is created automatically as `backend/notes.db`

### Build Commands

```bash
# Install Go dependencies
make install-deps

# Build backend binary
make backend

# Run backend server
make run-backend

# Clean build artifacts
make clean

# Setup development environment
make dev-setup
```

## Type Safety

The application maintains type safety between backend and frontend through:

1. **OpenAPI Specification**: `shared/openapi.yaml` defines the API contract
2. **Go Models**: Backend models in `backend/models.go` match the OpenAPI spec
3. **Swift Models**: Frontend models in `frontend/NotesApp/Models.swift` mirror the API types
4. **JSON Serialization**: Consistent field naming with snake_case (API) and camelCase (Swift)

## CORS Configuration

The backend includes CORS headers to allow the iOS app to connect during development:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type`
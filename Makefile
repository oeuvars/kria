.PHONY: backend frontend clean run-backend install-deps

# Install dependencies
install-deps:
	cd backend && go mod tidy

# Build backend
backend:
	cd backend && go build -o ../bin/notes-backend .

# Run backend
run-backend:
	cd backend && go run .

# Clean build artifacts
clean:
	rm -rf bin/
	rm -f backend/notes.db

# Development setup
dev-setup: install-deps
	mkdir -p bin

# Run full stack (backend only - iOS app needs Xcode)
run: backend
	./bin/notes-backend
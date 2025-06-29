package main

import (
	"database/sql"
	"time"
	_ "github.com/mattn/go-sqlite3"
)

type Database struct {
	db *sql.DB
}

func NewDatabase(dataSourceName string) (*Database, error) {
	db, err := sql.Open("sqlite3", dataSourceName)
	if err != nil {
		return nil, err
	}

	database := &Database{db: db}
	if err := database.createTables(); err != nil {
		return nil, err
	}

	return database, nil
}

func (d *Database) createTables() error {
	query := `
	CREATE TABLE IF NOT EXISTS notes (
		id TEXT PRIMARY KEY,
		title TEXT NOT NULL,
		content TEXT,
		created_at DATETIME NOT NULL,
		updated_at DATETIME NOT NULL
	);`

	_, err := d.db.Exec(query)
	return err
}

func (d *Database) CreateNote(note *Note) error {
	query := `INSERT INTO notes (id, title, content, created_at, updated_at) 
			  VALUES (?, ?, ?, ?, ?)`
	
	_, err := d.db.Exec(query, note.ID, note.Title, note.Content, note.CreatedAt, note.UpdatedAt)
	return err
}

func (d *Database) GetAllNotes() ([]Note, error) {
	query := `SELECT id, title, content, created_at, updated_at FROM notes ORDER BY updated_at DESC`
	
	rows, err := d.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notes []Note
	for rows.Next() {
		var note Note
		err := rows.Scan(&note.ID, &note.Title, &note.Content, &note.CreatedAt, &note.UpdatedAt)
		if err != nil {
			return nil, err
		}
		notes = append(notes, note)
	}

	return notes, nil
}

func (d *Database) GetNoteByID(id string) (*Note, error) {
	query := `SELECT id, title, content, created_at, updated_at FROM notes WHERE id = ?`
	
	var note Note
	err := d.db.QueryRow(query, id).Scan(&note.ID, &note.Title, &note.Content, &note.CreatedAt, &note.UpdatedAt)
	if err != nil {
		return nil, err
	}

	return &note, nil
}

func (d *Database) UpdateNote(id string, req UpdateNoteRequest) error {
	note, err := d.GetNoteByID(id)
	if err != nil {
		return err
	}

	if req.Title != "" {
		note.Title = req.Title
	}
	if req.Content != "" {
		note.Content = req.Content
	}
	note.UpdatedAt = time.Now()

	query := `UPDATE notes SET title = ?, content = ?, updated_at = ? WHERE id = ?`
	_, err = d.db.Exec(query, note.Title, note.Content, note.UpdatedAt, id)
	return err
}

func (d *Database) DeleteNote(id string) error {
	query := `DELETE FROM notes WHERE id = ?`
	_, err := d.db.Exec(query, id)
	return err
}
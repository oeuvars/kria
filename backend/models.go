package main

import (
	"time"
	"github.com/google/uuid"
)

type Note struct {
	ID        string    `json:"id" db:"id"`
	Title     string    `json:"title" db:"title" binding:"required"`
	Content   string    `json:"content" db:"content"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type CreateNoteRequest struct {
	Title   string `json:"title" binding:"required"`
	Content string `json:"content"`
}

type UpdateNoteRequest struct {
	Title   string `json:"title"`
	Content string `json:"content"`
}

type NotesResponse struct {
	Notes []Note `json:"notes"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

func NewNote(title, content string) *Note {
	now := time.Now()
	return &Note{
		ID:        uuid.New().String(),
		Title:     title,
		Content:   content,
		CreatedAt: now,
		UpdatedAt: now,
	}
}
package main

import (
	"net/http"
	"github.com/gin-gonic/gin"
)

// @title Notes API
// @version 1.0
// @description A simple notes API
// @host localhost:8080
// @BasePath /api/v1
func main() {
	db, err := NewDatabase("notes.db")
	if err != nil {
		panic(err)
	}

	r := gin.Default()
	
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type")
		
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		
		c.Next()
	})

	api := r.Group("/api/v1")
	{
		api.GET("/hello", hello())
		api.GET("/notes", getNotes(db))
		api.POST("/notes", createNote(db))
		api.GET("/notes/:id", getNoteByID(db))
		api.PUT("/notes/:id", updateNote(db))
		api.DELETE("/notes/:id", deleteNote(db))
	}

	r.Run(":8080")
}

// @Summary Get all notes
// @Description Get all notes
// @Tags notes
// @Accept json
// @Produce json
// @Success 200 {object} NotesResponse
// @Router /notes [get]
func getNotes(db *Database) gin.HandlerFunc {
	return func(c *gin.Context) {
		notes, err := db.GetAllNotes()
		if err != nil {
			c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
			return
		}
		c.JSON(http.StatusOK, NotesResponse{Notes: notes})
	}
}

// @Summary Create a new note
// @Description Create a new note
// @Tags notes
// @Accept json
// @Produce json
// @Param note body CreateNoteRequest true "Note to create"
// @Success 201 {object} Note
// @Failure 400 {object} ErrorResponse
// @Router /notes [post]
func createNote(db *Database) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req CreateNoteRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
			return
		}

		note := NewNote(req.Title, req.Content)
		if err := db.CreateNote(note); err != nil {
			c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
			return
		}

		c.JSON(http.StatusCreated, note)
	}
}

// @Summary Get a note by ID
// @Description Get a note by ID
// @Tags notes
// @Accept json
// @Produce json
// @Param id path string true "Note ID"
// @Success 200 {object} Note
// @Failure 404 {object} ErrorResponse
// @Router /notes/{id} [get]
func getNoteByID(db *Database) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		note, err := db.GetNoteByID(id)
		if err != nil {
			c.JSON(http.StatusNotFound, ErrorResponse{Error: "Note not found"})
			return
		}
		c.JSON(http.StatusOK, note)
	}
}

// @Summary Update a note
// @Description Update a note
// @Tags notes
// @Accept json
// @Produce json
// @Param id path string true "Note ID"
// @Param note body UpdateNoteRequest true "Note updates"
// @Success 200 {object} Note
// @Failure 400 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /notes/{id} [put]
func updateNote(db *Database) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		var req UpdateNoteRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
			return
		}

		if err := db.UpdateNote(id, req); err != nil {
			c.JSON(http.StatusNotFound, ErrorResponse{Error: "Note not found"})
			return
		}

		note, _ := db.GetNoteByID(id)
		c.JSON(http.StatusOK, note)
	}
}

// @Summary Delete a note
// @Description Delete a note
// @Tags notes
// @Accept json
// @Produce json
// @Param id path string true "Note ID"
// @Success 204
// @Failure 404 {object} ErrorResponse
// @Router /notes/{id} [delete]
func deleteNote(db *Database) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		if err := db.DeleteNote(id); err != nil {
			c.JSON(http.StatusNotFound, ErrorResponse{Error: "Note not found"})
			return
		}
		c.Status(http.StatusNoContent)
	}
}

// @Summary Hello endpoint
// @Description Simple hello endpoint for testing
// @Tags testing
// @Produce json
// @Success 200 {object} map[string]string
// @Router /hello [get]
func hello() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, World!",
			"status":  "API is running",
		})
	}
}
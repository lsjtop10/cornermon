package main

import (
	"log"
	"github.com/labstack/echo/v4"
)

func main() {
	log.Println("Cornermon Backend Starting...")
	e := echo.New()
	
	// Serve the auto-generated Swagger UI spec directly
	e.File("/openapi.yaml", "docs/swagger.yaml")
	e.File("/openapi.json", "docs/swagger.json")
	
	// TODO: Initialize HTTP handlers
	log.Fatal(e.Start(":8080"))
}

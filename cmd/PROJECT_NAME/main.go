package main

import (
	"fmt"
	"log"
	"os"

	"github.com/YOUR_USERNAME/PROJECT_NAME/internal/core"
)

const version = "0.1.0"

func main() {
	if len(os.Args) > 1 && os.Args[1] == "--version" {
		fmt.Printf("myapp version %s\n", version)
		return
	}

	app := core.NewApp()
	if err := app.Run(); err != nil {
		log.Fatalf("Application failed: %v", err)
	}
}
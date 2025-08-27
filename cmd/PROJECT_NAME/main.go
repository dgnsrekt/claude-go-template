// Package main provides the entry point for the PROJECT_NAME application.
package main

import (
	"fmt"
	"log"
	"os"

	"github.com/YOUR_USERNAME/PROJECT_NAME/internal/core"
)

const (
	version     = "0.1.0"
	versionFlag = "--version"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == versionFlag {
		fmt.Printf("myapp version %s\n", version) //nolint:forbidigo // Acceptable: version output to stdout
		return
	}

	app := core.NewApp()
	if err := app.Run(); err != nil {
		log.Fatalf("Application failed: %v", err)
	}
}

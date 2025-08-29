package core

import "fmt"

// App represents the main application structure.
type App struct {
	name string
}

// NewApp creates a new application instance.
func NewApp() *App {
	return &App{
		name: "PROJECT_NAME",
	}
}

// Run executes the main application logic.
func (a *App) Run() error {
	fmt.Printf("Hello from %s!\n", a.name) //nolint:forbidigo // Acceptable: main application output
	return nil
}

// GetName returns the application name.
func (a *App) GetName() string {
	return a.name
}

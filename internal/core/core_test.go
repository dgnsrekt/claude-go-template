package core

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewApp(t *testing.T) {
	app := NewApp()
	require.NotNil(t, app)
	assert.Equal(t, "myapp", app.GetName())
}

func TestApp_Run(t *testing.T) {
	tests := []struct {
		name    string
		wantErr bool
	}{
		{
			name:    "successful run",
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := NewApp()
			err := app.Run()

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestApp_GetName(t *testing.T) {
	app := NewApp()
	name := app.GetName()
	assert.Equal(t, "myapp", name)
}

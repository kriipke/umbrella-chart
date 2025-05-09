package cmd

import (
	"bytes"
	"fmt"
	"io"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestVersionCommand(t *testing.T) {
	version := "v1.0.0"
	cmd := newVersionCmd(version)
	b := bytes.NewBufferString("")
	cmd.SetOut(b)

	err := cmd.Execute()
	require.NoError(t, err)

	out, err := io.ReadAll(b)
	require.NoError(t, err)

	assert.Equal(t, fmt.Sprintf("mkchart: %s\n", version), string(out))
}

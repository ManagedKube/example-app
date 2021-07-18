package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

func TestDefault(t *testing.T) {
	assert.Equal(t, "one", "one")
}

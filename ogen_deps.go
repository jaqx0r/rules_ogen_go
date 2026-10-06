//go:build tools

// Package ogen_deps contains dependencies for compiling `ogen` generated code.
package ogen_deps

import (
	_ "github.com/go-faster/errors"
	_ "github.com/go-faster/jx"
	_ "github.com/ogen-go/ogen/conv"
	_ "github.com/ogen-go/ogen/json"
	_ "github.com/ogen-go/ogen/middleware"
	_ "github.com/ogen-go/ogen/ogenerrors"
	_ "github.com/ogen-go/ogen/ogenregex"
	_ "github.com/ogen-go/ogen/otelogen"
	_ "github.com/ogen-go/ogen/validate"
	_ "go.opentelemetry.io/otel"
	_ "go.opentelemetry.io/otel/attribute"
	_ "go.opentelemetry.io/otel/codes"
	_ "go.opentelemetry.io/otel/metric"
	_ "go.opentelemetry.io/otel/semconv/v1.39.0"
	_ "go.opentelemetry.io/otel/trace"
)

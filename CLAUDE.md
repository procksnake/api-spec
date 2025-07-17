# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **OpenAPI 3.0 specification project** for a **Large Language Model Gateway API** that provides authentication, RAG (Retrieval-Augmented Generation), chat completion proxy, and Azure integration services. The project focuses on generating type-safe client and server code for TypeScript and Go from OpenAPI specifications.

## Common Development Commands

### Build and Code Generation

```bash
# Bundle all OpenAPI specification files into a single file
make bundled-api

# Generate TypeScript client code and types
make ts-api-gen

# Generate Go server code with custom templates
make gen-go-server

# Generate Go client code  
make gen-go-client

# Generate all code (TypeScript + Go)
make gen

# Alternative Go code generation using ogen
make ogen

# Clean generated files
make clean
```

### Prerequisites Setup

```bash
# Install required tools
npm install -g @redocly/cli
npm install -D openapi-typescript
go install github.com/ogen-go/ogen/cmd/ogen@latest
pip install pyyaml
```

## Architecture Overview

### Modular OpenAPI Structure

- **`api/openapi.yaml`** - Main specification file that references all other components
- **`api/paths/`** - API endpoint definitions split by domain (auth, rag, chat, etc.)
- **`api/components/schemas/`** - Reusable data models and types
- **`api/components/security.yaml`** - Security scheme definitions

### Code Generation Pipeline

1. **Bundle Phase**: All YAML files are merged into `bundled/api.yaml` using Redocly CLI
2. **TypeScript Generation**: Creates client code in `frontend/src/api/` and types in `frontend/src/types/`
3. **Go Generation**: Creates server code in `backend/internal/api/` and client code in `backend/pkg/client/`

### Key API Domains

#### Authentication System

- JWT-based authentication with access/refresh tokens
- API key management for service-to-service communication
- Token validation and refresh endpoints

#### RAG (Retrieval-Augmented Generation)

- Document upload and processing via multipart form data
- Vector search integration with Azure AI Search
- Session-based conversation management with query history
- Semantic search with configurable ranking and filtering
- Response generation with customizable GPT models and parameters

#### Chat Completions

- Proxy endpoint for direct LLM interactions
- Bypasses RAG system for direct chat completion requests

#### Azure Integration

- Azure Storage integration with SAS token generation
- Azure AI Search integration for document indexing and retrieval
- Blob storage management for uploaded documents

## Custom Code Generation

### Go Templates

- **`go_templates/enum.tmpl`** - Generates error code enums
- **`go_templates/error_codes.tmpl`** - Generates structured error codes
- **`fix_go_errors.sh`** - Post-processes generated Go code to fix common issues

### TypeScript Processing

- **`scripts/gen_common.py`** - Generates common TypeScript types
- **`rename-file.py`** - Renames generated files to follow naming conventions

## API Design Patterns

### Response Structure

All endpoints follow a consistent response pattern using `APIResponse` base type:

```yaml
APIResponse:
  type: object
  properties:
    success: boolean
    message: string
    data: object  # Specific response data
    error: object # Error details if applicable
```

### Pagination

List endpoints include pagination metadata:

```yaml
Pagination:
  type: object
  properties:
    page: integer
    limit: integer
    total: integer
    totalPages: integer
```

### Error Handling

- Structured error codes with enums
- Consistent error response format
- HTTP status codes aligned with REST conventions

## Development Workflow

1. **Modify OpenAPI specs** in `api/` directory
2. **Run `make bundled-api`** to create bundled specification
3. **Run `make gen`** to generate client/server code
4. **Test generated code** in consuming applications
5. **Iterate** on specification based on implementation feedback

## File Structure Notes

- Generated code should not be committed to version control
- Custom templates in `go_templates/` can be modified to change Go code generation
- Python scripts in `scripts/` handle post-processing of generated code
- The `bundled/` directory contains the final merged OpenAPI specification

## How to check for fix_go_errors

- Use make and check return code

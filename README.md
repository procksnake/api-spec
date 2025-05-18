# Install for frontend

npm install -D openapi-typescript

# Create for frontend

npx openapi-typescript api.yaml --output frontend/src/types/api.d.ts

# install for go

go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@v1.16.3
export PATH="$HOME/go/bin:$PATH"

sudo npm install -g @redocly/cli

go install github.com/ogen-go/ogen/cmd/ogen@latest

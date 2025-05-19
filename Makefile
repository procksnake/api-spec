API_SPEC = api/api-spec.yaml
TS_GEN = frontend/src/types/api.d.ts
TS_API_GEN = frontend/src/api
COMMON_GEN = frontend/src/types/common.ts
GO_GEN = backend/internal/model/api.go
OGEN = backend/internal/api
GO_CLIENT_GEN = backend/pkg/client/api_client.go
GO_SERVER_GEN = backend/internal/api/server.go
API_DIR = api
BUNDLED_DIR = bundled
API_YAML_FILES := $(shell find $(API_DIR) -name "*.yaml")
BUNDLED_API = $(BUNDLED_DIR)/api.yaml
RENAME_SCRIPT = rename-file.py 

.PHONY: gen-ts gen-common gen-go gen ts-api-gen ogen clean

gen: ts-api-gen gen-go

$(BUNDLED_DIR):
	mkdir -p $@

# API 번들링 규칙
$(BUNDLED_API): $(API_YAML_FILES) | $(BUNDLED_DIR)
	npx @redocly/cli bundle $(API_DIR)/openapi.yaml -o $@

# TypeScript 코드 생성 규칙
$(TS_API_GEN): $(BUNDLED_API) $(RENAME_SCRIPT)
	npx openapi-typescript-codegen --input $< --output $@ --useOptions --useUnionTypes
	python $(RENAME_SCRIPT) 

ts-api-gen: $(TS_API_GEN)

$(GO_GEN): $(BUNDLED_API)
	mkdir -p backend/internal/model
	oapi-codegen -package model -generate types -o $@ $< 

gen-go-models: $(GO_GEN)

$(OGEN): $(BUNDLED_API)
	@echo here
	ogen --target $@ --package api --clean $< 

ogen: $(OGEN)

$(GO_SERVER_GEN): $(BUNDLED_API)
	mkdir -p backend/internal/api
	oapi-codegen -package api -generate gin -o $@ $< 

gen-go-server: $(GO_SERVER_GEN)

$(GO_CLIENT_GEN): $(BUNDLED_API)
	mkdir -p backend/pkg/client
	oapi-codegen -package client -generate gin -o $@ $< 

gen-go-client: $(GO_CLIENT_GEN)

gen-go: gen-go-models gen-go-client gen-go-server ogen

clean:
	rm -f $(TS_GEN) $(COMMON_GEN) $(GO_GEN) $(GO_CLIENT_GEN)

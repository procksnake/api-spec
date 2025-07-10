API_SPEC = api/api-spec.yaml
TS_GEN = frontend/src/types/api.d.ts
TS_API_GEN = frontend/src/api
COMMON_GEN = frontend/src/types/common.ts
GO_TYPES_GEN = backend/internal/api/types.gen.go
OGEN = backend/internal/api
GO_CLIENT_GEN = backend/pkg/client/api_client.go
GO_SERVER_GEN = backend/internal/api/server.gen.go
API_DIR = api
BUNDLED_DIR = bundled
API_YAML_FILES := $(shell find $(API_DIR) -name "*.yaml")
BUNDLED_API = $(BUNDLED_DIR)/api.yaml
RENAME_SCRIPT = rename-file.py 
FIX_GO_ERROR_SCRIPT = fix_go_errors.sh
ENUM_GO_SCRIPT = go_gen_error_enum.py
ENUM_GO_OUTPUT = backend/internal/api/error_code.gen.go

.PHONY: gen-ts gen-common gen-go gen ts-api-gen ogen clean bundled-api

gen: ts-api-gen gen-go

$(BUNDLED_DIR):
	mkdir -p $@

$(BUNDLED_API): $(API_YAML_FILES) | $(BUNDLED_DIR)
	npx @redocly/cli bundle $(API_DIR)/openapi.yaml -o $@

bundled-api: $(BUNDLED_API)

$(TS_API_GEN): $(BUNDLED_API) $(RENAME_SCRIPT)
	npx openapi-typescript-codegen --input $< --output $@ --useOptions --useUnionTypes
	python $(RENAME_SCRIPT) 

ts-api-gen: $(TS_API_GEN)

$(GO_TYPES_GEN): $(BUNDLED_API)
	mkdir -p backend/internal/api
	oapi-codegen -package api -generate types -o $@ $< 

gen-go-types: $(GO_TYPES_GEN)


$(GO_SERVER_GEN): $(BUNDLED_API) $(FIX_GO_ERROR_SCRIPT)
	mkdir -p backend/internal/api
	#oapi-codegen -package api -generate gin -o $@ $< 
	oapi-codegen -package api -generate gin,types,spec -templates go_templates -o $@ $(BUNDLED_API)
	/bin/bash $(FIX_GO_ERROR_SCRIPT) $@

gen-go-server: $(GO_SERVER_GEN)

$(GO_CLIENT_GEN): $(BUNDLED_API)
	mkdir -p backend/pkg/client
	oapi-codegen -package client -generate gin -o $@ $< 

gen-go-client: $(GO_CLIENT_GEN)

$(OGEN): $(BUNDLED_API)
	@echo here
	ogen --target $@ --package api --clean $<

ogen: $(OGEN)

gen-go: gen-go-server

clean:
	rm -f $(TS_GEN) $(COMMON_GEN) $(GO_GEN) $(GO_CLIENT_GEN)

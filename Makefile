API_SPEC = api/api-spec.yaml
TS_GEN = frontend/src/types/api.d.ts
COMMON_GEN = frontend/src/types/common.ts
GO_GEN = backend/pkg/model/api.go
GO_CLIENT_GEN = backend/pkg/client/api_client.go
GO_SERVER_GEN = backend/internal/api/server.go

.PHONY: gen-ts gen-common gen-go gen clean

# 전체 수행
gen: gen-ts gen-common gen-go

# TS 타입 생성 (OpenAPI → TS)
$(TS_GEN): $(API_SPEC)
	npx openapi-typescript $(API_SPEC) --output $(TS_GEN)
gen-ts: $(TS_GEN)

# 공통 타입 생성 (TS → common.ts)
$(COMMON_GEN): $(TS_GEN) scripts/gen_common.py
	python3 scripts/gen_common.py
gen-common: $(COMMON_GEN)

# Go 모델 생성 (OpenAPI → Go structs)
$(GO_GEN): $(API_SPEC)
	mkdir -p backend/pkg/model
	oapi-codegen -package model -generate types -o $(GO_GEN) $(API_SPEC)
gen-go-models: $(GO_GEN)

# Go 서버 생성 (OpenAPI → Go server)
$(GO_SERVER_GEN): $(API_SPEC)
	mkdir -p backend/internal/api
	oapi-codegen -package api -generate gin -o $(GO_SERVER_GEN) $(API_SPEC)

gen-go-server: $(GO_SERVER_GEN)

# Go 클라이언트 생성 (OpenAPI → Go client)
$(GO_CLIENT_GEN): $(API_SPEC)
	mkdir -p backend/pkg/client
	oapi-codegen -package client -generate client -o $(GO_CLIENT_GEN) $(API_SPEC)
gen-go-client: $(GO_CLIENT_GEN)

# Go 전체 생성 (모델 + 클라이언트)
gen-go: gen-go-models gen-go-client gen-go-server

# 선택적 clean
clean:
	rm -f $(TS_GEN) $(COMMON_GEN) $(GO_GEN) $(GO_CLIENT_GEN)

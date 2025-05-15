API_SPEC = api/api-spec.yaml
TS_GEN = frontend/src/types/api.d.ts
COMMON_GEN = frontend/src/types/common.ts

.PHONY: gen-ts gen-common gen clean

# 전체 수행
gen: gen-ts gen-common

# TS 타입 생성 (OpenAPI → TS)
$(TS_GEN): $(API_SPEC)
	npx openapi-typescript $(API_SPEC) --output $(TS_GEN)

gen-ts: $(TS_GEN)

# 공통 타입 생성 (TS → common.ts)
$(COMMON_GEN): $(TS_GEN) scripts/gen_common.py
	python3 scripts/gen_common.py

gen-common: $(COMMON_GEN)

# 선택적 clean
clean:
	rm -f $(TS_GEN) $(COMMON_GEN)

import re
from pathlib import Path

API_FILE = Path("frontend/src/types/api.d.ts")
OUT_FILE = Path("frontend/src/types/common.ts")

# 파일 읽기
if not API_FILE.exists():
    raise FileNotFoundError("❌ api.d.ts not found. Run openapi-typescript first.")

content = API_FILE.read_text(encoding="utf-8")

# components.schemas 블럭 추출
match = re.search(r"schemas:\s*{\s*(.*?)\s*}\s*,?\n", content, re.DOTALL)
if not match:
    raise ValueError("❌ schemas block not found")

schema_block = match.group(1)

# 타입 이름 추출
type_names = re.findall(
    r"(\w+):\s*(?:components\[(?:\"|\')schemas(?:\"|\')]\[(?:\"|\')[\w]+(?:\"|\')]\s*&\s*)?{",
    schema_block,
)

added_names = []

if not type_names:
    raise ValueError("❌ No types found under components.schemas")

# common.ts 생성
lines = ["import type { components } from './api'\n"]

for name in type_names:
    print(name)

    if name.endswith("Base"):
        continue

    added_names.append(name)

    # 기본 타입 정의
    lines.append(f"export type {name} = components['schemas']['{name}']")

    """
    # APIResponseUserTypedyped 병합 타입 생성 조건: APIResponse로 시작하거나, APIResponse가 포함됨
    if (
        "APIResponse" in name or name.startswith("APIResponse")
    ) and name != "APIResponse":
        # 예: APIResponseUsers → Users → User (단복수 자동 판별)
        suffix = name.replace("APIResponse", "")
        base = suffix.rstrip("s")  # Users → User
        ref = f"components['schemas']['{base}']"
        data_type = f"{ref}[]" if suffix.endswith("s") else ref
        lines.append(
            f"export type {name}Typed = components['schemas']['APIResponse'] & {{"
        )
        lines.append(f"  data?: {data_type};")
        lines.append("}")
    """

# 파일 출력
OUT_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"✅ common.ts generated with: {', '.join(added_names)}")

#!/usr/bin/env python3
import os
import re
import sys

# 약어 목록 (모두 소문자로 저장)
ACRONYMS = ["api", "url", "http", "json", "xml", "jwt", "sql", "rest"]


def convert_to_kebab_case(name):
    """
    PascalCase를 kebab-case로 변환하되, 약어는 하나의 단어로 취급
    """
    # 정규 표현식으로 단어 경계 찾기 (대문자 앞에 '-' 추가)
    # 첫 글자는 항상 소문자로 시작
    s1 = re.sub("(.)([A-Z][a-z]+)", r"\1-\2", name)
    s2 = re.sub("([a-z0-9])([A-Z])", r"\1-\2", s1)

    # 모두 소문자로 변환
    kebab_case = s2.lower()

    # 약어 특수 처리 (예: a-p-i -> api)
    for acronym in ACRONYMS:
        # 약어가 '-'로 분리된 경우 합치기
        separated_acronym = "-".join(list(acronym))
        kebab_case = kebab_case.replace(separated_acronym, acronym)

    return kebab_case


def create_rename_mapping(directory):
    """
    모든 파일의 이름 변경 매핑을 생성
    """
    rename_map = {}

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".ts"):
                # 확장자 제외한 파일 이름
                base_name = os.path.splitext(file)[0]

                # 파일이 이미 kebab-case인지 확인 (모두 소문자이고 '-'만 포함)
                if (
                    base_name.islower()
                    and not any(c.isupper() for c in base_name)
                    and not re.search(r"[^a-z0-9\-]", base_name)
                ):
                    continue

                # PascalCase 또는 camelCase를 kebab-case로 변환
                kebab_name = convert_to_kebab_case(base_name)

                # Service.ts 파일은 특별 처리
                if base_name.endswith("Service"):
                    service_name = convert_to_kebab_case(
                        base_name[:-7]
                    )  # 'Service' 제거
                    kebab_name = f"{service_name}.service"

                if kebab_name != base_name:
                    new_file = kebab_name + ".ts"

                    # 파일 경로 계산 (directory를 기준으로 한 상대 경로)
                    rel_path = os.path.relpath(os.path.join(root, file), directory)
                    rel_new_path = os.path.relpath(
                        os.path.join(root, new_file), directory
                    )

                    # 매핑 추가 (확장자 없는 모듈 경로)
                    old_module = os.path.splitext(rel_path)[0]
                    new_module = os.path.splitext(rel_new_path)[0]
                    rename_map[old_module] = new_module

    return rename_map


def rename_files_and_update_imports(directory):
    """파일 이름을 변경하고 import 문을 업데이트"""
    # 먼저 모든 파일의 이름 변경 매핑 생성
    rename_map = create_rename_mapping(directory)

    # 디버깅: 생성된 매핑 출력
    print("생성된 파일 매핑:")
    for old, new in rename_map.items():
        print(f"  {old} -> {new}")

    # 모든 .ts 파일 순회하면서 import 문 업데이트
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".ts"):
                file_path = os.path.join(root, file)

                # 파일 내용 읽기
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                # import 문 업데이트
                modified_content = content
                for old_module, new_module in rename_map.items():
                    # 상대 경로 import 패턴 찾기 (예: '../models/UserCreateRequest')
                    import_pattern = (
                        r"from\s+['\"](.+/)?("
                        + os.path.basename(old_module)
                        + r")['\"]"
                    )

                    # 찾은 패턴 대체
                    def replace_import(match):
                        prefix = match.group(1) or ""
                        return f"from '{prefix}{os.path.basename(new_module)}'"

                    modified_content = re.sub(
                        import_pattern, replace_import, modified_content
                    )

                # 내용이 변경되었다면 파일 업데이트
                if modified_content != content:
                    print(f"Import 경로 업데이트: {file_path}")
                    with open(file_path, "w", encoding="utf-8") as f:
                        f.write(modified_content)

    # 파일 이름 변경 (import 수정 후에 수행)
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".ts"):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, directory)
                module_name = os.path.splitext(rel_path)[0]

                if module_name in rename_map:
                    new_name = os.path.basename(rename_map[module_name]) + ".ts"
                    new_path = os.path.join(root, new_name)

                    # 파일 이름 변경
                    if not os.path.exists(new_path):
                        print(f"파일 이름 변경: {file} -> {new_name}")
                        os.rename(file_path, new_path)
                    else:
                        print(f"경고: {new_name}이 이미 존재합니다. 건너뜁니다.")


if __name__ == "__main__":
    # 기본 디렉토리는 현재 위치의 frontend/src/api
    default_dir = os.path.join("frontend", "src", "api")

    # 명령행 인수로 디렉토리를 지정할 수 있음
    directory = sys.argv[1] if len(sys.argv) > 1 else default_dir

    rename_files_and_update_imports(directory)
    print("파일 이름 변경 및 import 경로 업데이트 완료!")

import re
import sys


def remove_middleware_blocks_simple(path: str):
    block = """\tfor _, middleware := range siw.HandlerMiddlewares {\n\t\tmiddleware(c)\n\t\tif c.IsAborted() {\n\t\t\treturn\n\t\t}\n\t}\n"""

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    count = content.count(block)
    if count == 0:
        print("ℹ️ No exact middleware blocks found.")
        return

    content = content.replace(block, "")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"✅ Removed {count} middleware block(s) (exact match)")


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else ""
    remove_middleware_blocks_simple(path)

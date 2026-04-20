#!/usr/bin/env python3
"""
GNU Lightning Zig Binding Coverage Analyzer
"""

import re
from pathlib import Path


def extract_lightning_codes(content: str) -> set:
    pattern = r'jit_code_([a-zA-Z_0-9]+),'
    return set(re.findall(pattern, content))


def extract_zig_codes(content: str) -> set:
    # enum usage: c.jit_code_add
    enum_pattern = r'c\.jit_code_([a-zA-Z_0-9]+)'
    codes = set(re.findall(enum_pattern, content))

    # function calls: c._jit_add (maps to jit_code_add)
    func_pattern = r'c\._jit_([a-zA-Z_0-9]+)'
    funcs = set(re.findall(func_pattern, content))

    codes.update(funcs)
    return codes


def main():
    root = Path(__file__).parent.resolve()
    lightning_path = root / 'libs' / 'lightning' / 'include' / 'lightning.h'
    zig_path = root / 'src' / 'zjit.zig'

    with open(lightning_path, 'r') as f:
        lightning_content = f.read()

    with open(zig_path, 'r') as f:
        zig_content = f.read()

    lightning_codes = extract_lightning_codes(lightning_content)
    zig_codes = extract_zig_codes(zig_content)

    skip_codes = {'data', 'save', 'load', 'skip', 't'}
    missing = sorted(lightning_codes - zig_codes - skip_codes)

    covered = len(lightning_codes - skip_codes - set(missing))
    total = len(lightning_codes - skip_codes)
    coverage_pct = covered / total * 100 if total > 0 else 0

    print(f"coverage: {covered}/{total} ({coverage_pct:.1f}%)")

    if missing:
        print(f"\nmissing ({len(missing)}):")
        for code in missing:
            print(f"  - {code}")


if __name__ == '__main__':
    main()

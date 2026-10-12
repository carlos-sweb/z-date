#!/usr/bin/env python3
"""Check that every public Zig function has an immediately preceding doc comment."""
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[1]
missing, total = [], 0
for path in sorted((root / 'src').glob('*.zig')):
    lines = path.read_text().splitlines()
    for i, line in enumerate(lines):
        if re.search(r'^\s*pub\s+(?:inline\s+)?fn\s+', line):
            total += 1
            if i == 0 or not lines[i-1].lstrip().startswith('///'):
                missing.append(f'{path.relative_to(root)}:{i+1}: {line.strip()}')
if missing:
    raise SystemExit('Missing Zig doc comments:\n' + '\n'.join(missing))
print(f'Zig documentation coverage: {total}/{total} public functions have doc comments.')

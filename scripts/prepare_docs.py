#!/usr/bin/env python3
"""Prepare Zig-generated API docs for static hosting without altering the UI."""
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[1]
output = root / 'zig-out/docs'
for name in ['index.html', 'main.js', 'main.wasm', 'sources.tar']:
    if not (output / name).is_file():
        raise SystemExit(f'Missing generated documentation: {name}; run zig build docs first')
version = re.search(r'\.version\s*=\s*"([^"]+)"', (root / 'build.zig.zon').read_text()).group(1)
index = output / 'index.html'
html = re.sub(r'<title>.*?</title>', f'<title>Z-Date {version} API Reference</title>', index.read_text(), flags=re.DOTALL)
index.write_text(html)
(output / '.nojekyll').write_text('')
print(f'Prepared Zig-generated API reference for Z-Date {version}: {output}')

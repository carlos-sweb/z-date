#!/usr/bin/env python3
"""Extract the immutable benchmark baseline, verifying its SHA-256 first."""
import hashlib
import json
import pathlib
import sys
import tarfile

archive, manifest, destination = map(pathlib.Path, sys.argv[1:])
expected = json.loads(manifest.read_text())["sha256"]
if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
    raise SystemExit("Baseline SHA-256 mismatch")
destination.mkdir(parents=True, exist_ok=True)
with tarfile.open(archive) as source:
    source.extractall(destination, filter="data")

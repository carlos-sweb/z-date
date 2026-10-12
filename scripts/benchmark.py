#!/usr/bin/env python3
"""Reproducible paired A/B benchmark; saves raw samples, medians and metadata."""
import argparse
import csv
import hashlib
import json
import os
import pathlib
import platform
import statistics
import subprocess
import sys
import time
from collections import defaultdict

ROOT = pathlib.Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--runs', type=int, default=3, help='independent process runs (7 alternating pairs each)')
p.add_argument('--mode', choices=['fast', 'safe'], default='fast')
p.add_argument('--cpu', type=int, help='Linux CPU affinity; default first available CPU')
args = p.parse_args()
if args.runs < 1:
    p.error('--runs must be positive')
version = subprocess.check_output(['zig', 'version'], cwd=ROOT, text=True).strip()
print(f'Compilando A/B con Zig {version}, modo {args.mode}...', flush=True)
subprocess.run(['zig', 'build', 'benchmark-build', f'-Doptimize={args.mode}', '-j4', '--summary', 'none'], cwd=ROOT, check=True)
allowed = sorted(os.sched_getaffinity(0)) if hasattr(os, 'sched_getaffinity') else []
cpu = args.cpu if args.cpu is not None else (allowed[0] if allowed else None)
if cpu is not None and allowed and cpu not in allowed:
    p.error(f'CPU {cpu} not in allowed set {allowed}')
rows, raw, allocs = [], [], {}
for run in range(args.runs):
    print(f'Midiendo proceso {run+1}/{args.runs}, CPU {cpu}, 7 pares por caso...', flush=True)
    def affinity():
        if cpu is not None:
            os.sched_setaffinity(0, {cpu})
    result = subprocess.run([str(ROOT / 'zig-out/bin/zdate-benchmark')], cwd=ROOT, text=True, capture_output=True,
                            preexec_fn=affinity if allowed else None)
    raw.append(f'# process {run}\n' + result.stdout + result.stderr)
    if result.returncode:
        sys.stderr.write(result.stderr)
        raise SystemExit(result.returncode)
    for line in (result.stdout + result.stderr).splitlines():
        if line.startswith('RESULT,'):
            _, case, profile, round_no, old, new, count, checksum = line.split(',')
            rows.append(dict(process=run, case=case, profile=profile, round=int(round_no),
                             before_ns=int(old), after_ns=int(new), operations=int(count), checksum=int(checksum)))
        elif line.startswith('ALLOC,'):
            _, case, old, new, old_bytes, new_bytes = line.split(',')
            measured = dict(before=int(old), after=int(new), before_requested_bytes=int(old_bytes), after_requested_bytes=int(new_bytes))
            if case in allocs and allocs[case] != measured:
                raise SystemExit(f'Allocation count changed between runs: {case}')
            allocs[case] = measured
if not rows:
    raise SystemExit('No benchmark samples received')
groups = defaultdict(list)
for row in rows:
    groups[row['case'], row['profile']].append(row)
expected = args.runs * 7
summary = []
for (case, profile), samples in groups.items():
    if len(samples) != expected:
        raise SystemExit(f'Missing samples for {case}/{profile}')
    old = [s['before_ns']/s['operations'] for s in samples]
    new = [s['after_ns']/s['operations'] for s in samples]
    ratios = [a/b for a,b in zip(old,new)]
    a, b = statistics.median(old), statistics.median(new)
    q = statistics.quantiles(ratios, n=10)
    summary.append(dict(case=case, profile=profile, before_ns_per_op=a, after_ns_per_op=b,
                        speedup=a/b, time_reduction_percent=100*(1-b/a),
                        paired_speedup_p10=q[0], paired_speedup_p90=q[-1], samples=len(samples)))
source = hashlib.sha256()
for path in sorted((ROOT/'src').rglob('*')) + [ROOT/'benchmarks/compare.zig']:
    if path.is_file():
        source.update(str(path.relative_to(ROOT)).encode()); source.update(path.read_bytes())
metadata = dict(zig=version, optimize=args.mode, host=platform.platform(), cpu_affinity=cpu,
                runs=args.runs, pairs_per_run=7, input_samples=4096, allocator='std.heap.smp_allocator',
                clock='std.Io.Clock.awake', source_sha256=source.hexdigest(),
                baseline=json.loads((ROOT/'benchmarks/baseline.json').read_text()),
                measured_at=time.strftime('%Y-%m-%dT%H:%M:%S%z'))
output = ROOT/'benchmarks'/f'results-{args.mode}'
output.with_suffix('.raw.txt').write_text('\n'.join(raw))
with output.with_suffix('.csv').open('w', newline='') as file:
    writer = csv.DictWriter(file, fieldnames=list(rows[0]), lineterminator='\n'); writer.writeheader(); writer.writerows(rows)
output.with_suffix('.json').write_text(json.dumps(dict(metadata=metadata, results=summary, allocations=allocs), indent=2)+'\n')
lines = [f'# Benchmark A/B — Zig {version}, {args.mode}', '',
         f'{args.runs} procesos × 7 pares = {expected} muestras por versión/caso; 4096 entradas deterministas.',
         f'CPU fija: {cpu}. Calentamiento y repetición adaptativa (mínimo 15 ms por bloque).',
         'Orden A/B alternado; ambas versiones en el mismo ejecutable y modo de compilación.',
         'Los checksums de ambas versiones coinciden en cada par. Los tiempos incluyen el bucle y, en formato, asignación/liberación y consumo de todos los bytes.', '',
         'Valores: mediana en ns por operación. Reducción = 100 × (1 − nuevo/anterior).',
         'Los percentiles 10–90 de aceleración emparejada muestran dispersión, no un intervalo de confianza.', '',
         '| Caso | Entradas | Anterior ns/op | Nuevo ns/op | Aceleración | Menos tiempo | P10–P90 |',
         '|---|---|---:|---:|---:|---:|---|']
for s in summary:
    lines.append(f"| {s['case']} | {s['profile']} | {s['before_ns_per_op']:.1f} | {s['after_ns_per_op']:.1f} | {s['speedup']:.2f}× | {s['time_reduction_percent']:.1f}% | {s['paired_speedup_p10']:.2f}–{s['paired_speedup_p90']:.2f}× |")
lines += ['', '## Asignaciones de salida', '', '| Caso | Anterior | Nuevo |', '|---|---:|---:|']
for case, counts in allocs.items():
    lines.append(f"| {case} | {counts['before']} | {counts['after']} |")
lines += ['', '## Alcance', '',
          '- full_range: ±8.64e15 ms, con fechas negativas y años expandidos.',
          '- history: timestamps aleatorios entre 2000 y 2030, America/Santiago.',
          '- future_clustered: timestamps aleatorios dentro de 2200, favorece reutilizar transiciones.',
          '- future_random: timestamps aleatorios entre 2100 y aproximadamente 10098, casi todos misses de caché.',
          '- utc_ymd: tres getters por operación. normalize: normalización de un día con +90.',
          '- parse_legacy/parse_slash: strings variables de años 2000–2029. locale_numeric/locale_time: en; locale_long: es.',
          '- No representan un porcentaje global de mejora de una aplicación. La ruta WASM mantiene el cálculo POSIX sin caché.',
          '- Copia anterior: baseline-zig-0.17.tar.gz; hash y metadatos en baseline.json.',
          '- Repetir: python3 scripts/benchmark.py --runs 3 --mode '+args.mode, '']
output.with_suffix('.md').write_text('\n'.join(lines))
print('\n'.join(lines))

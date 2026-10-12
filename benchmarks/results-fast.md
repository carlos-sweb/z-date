# Benchmark A/B — Zig 0.17.0, fast

3 procesos × 7 pares = 21 muestras por versión/caso; 4096 entradas deterministas.
CPU fija: 0. Calentamiento y repetición adaptativa (mínimo 15 ms por bloque).
Orden A/B alternado; ambas versiones en el mismo ejecutable y modo de compilación.
Los checksums de ambas versiones coinciden en cada par. Los tiempos incluyen el bucle y, en formato, asignación/liberación y consumo de todos los bytes.

Valores: mediana en ns por operación. Reducción = 100 × (1 − nuevo/anterior).
Los percentiles 10–90 de aceleración emparejada muestran dispersión, no un intervalo de confianza.

| Caso | Entradas | Anterior ns/op | Nuevo ns/op | Aceleración | Menos tiempo | P10–P90 |
|---|---|---:|---:|---:|---:|---|
| utc_day | full_range | 36.7 | 5.9 | 6.22× | 83.9% | 6.08–7.41× |
| utc_hour | full_range | 28.3 | 5.1 | 5.57× | 82.1% | 5.50–8.02× |
| utc_minute | full_range | 28.6 | 5.1 | 5.62× | 82.2% | 5.52–7.41× |
| utc_second | full_range | 28.7 | 5.1 | 5.62× | 82.2% | 5.48–5.86× |
| utc_ms | full_range | 28.5 | 3.0 | 9.37× | 89.3% | 9.11–9.60× |
| utc_ymd | full_range | 65.3 | 14.3 | 4.57× | 78.1% | 4.40–4.73× |
| calendar | full_range | 29.9 | 16.3 | 1.84× | 45.5% | 1.74–1.95× |
| components | full_range | 18.5 | 8.4 | 2.22× | 54.9% | 2.13–2.29× |
| normalize | full_range | 34.3 | 16.5 | 2.08× | 51.9% | 1.99–2.16× |
| set_utc_hour | full_range | 48.1 | 10.5 | 4.59× | 78.2% | 4.54–6.35× |
| set_utc_ms | full_range | 46.7 | 11.8 | 3.97× | 74.8% | 3.91–5.99× |
| iso | full_range | 66.3 | 45.7 | 1.45× | 31.0% | 1.41–2.14× |
| parse_iso | full_range | 45.4 | 32.0 | 1.42× | 29.5% | 1.31–1.50× |
| local_day | history | 64.1 | 32.3 | 1.98× | 49.6% | 1.89–2.29× |
| local_hour | history | 55.4 | 32.2 | 1.72× | 41.9% | 1.70–1.81× |
| set_local_hour | history | 125.0 | 69.0 | 1.81× | 44.8% | 1.76–2.33× |
| offset | history | 29.5 | 29.0 | 1.02× | 1.7% | 0.98–1.04× |
| locale_numeric | history | 398.9 | 191.2 | 2.09× | 52.1% | 1.75–2.15× |
| local_day | future_clustered | 237.4 | 17.7 | 13.45× | 92.6% | 13.30–14.72× |
| local_hour | future_clustered | 229.0 | 19.8 | 11.55× | 91.3% | 11.45–14.38× |
| set_local_hour | future_clustered | 633.5 | 48.1 | 13.17× | 92.4% | 12.50–14.15× |
| offset | future_clustered | 202.6 | 15.9 | 12.76× | 92.2% | 12.41–13.53× |
| locale_numeric | future_clustered | 717.9 | 171.0 | 4.20× | 76.2% | 4.12–4.33× |
| local_day | future_random | 240.0 | 157.1 | 1.53× | 34.5% | 1.45–1.61× |
| local_hour | future_random | 231.6 | 156.3 | 1.48× | 32.5% | 1.41–1.53× |
| set_local_hour | future_random | 637.6 | 208.7 | 3.06× | 67.3% | 2.82–3.26× |
| offset | future_random | 209.1 | 154.3 | 1.36× | 26.2% | 1.29–1.43× |
| locale_numeric | future_random | 721.5 | 325.0 | 2.22× | 55.0% | 2.12–2.33× |
| time_string | history | 109.2 | 91.1 | 1.20× | 16.5% | 1.15–1.27× |
| locale_time | history | 145.0 | 105.6 | 1.37× | 27.1% | 1.31–1.44× |
| locale_long | history | 388.0 | 198.9 | 1.95× | 48.7% | 1.90–2.06× |
| parse_legacy | history | 137.3 | 118.1 | 1.16× | 14.0% | 1.07–1.28× |
| parse_slash | history | 117.5 | 98.4 | 1.19× | 16.2% | 1.13–1.33× |

## Asignaciones de salida

| Caso | Anterior | Nuevo |
|---|---:|---:|
| locale_numeric | 7 | 1 |
| locale_long | 7 | 1 |
| locale_time | 2 | 1 |

## Alcance

- full_range: ±8.64e15 ms, con fechas negativas y años expandidos.
- history: timestamps aleatorios entre 2000 y 2030, America/Santiago.
- future_clustered: timestamps aleatorios dentro de 2200, favorece reutilizar transiciones.
- future_random: timestamps aleatorios entre 2100 y aproximadamente 10098, casi todos misses de caché.
- utc_ymd: tres getters por operación. normalize: normalización de un día con +90.
- parse_legacy/parse_slash: strings variables de años 2000–2029. locale_numeric/locale_time: en; locale_long: es.
- No representan un porcentaje global de mejora de una aplicación. La ruta WASM mantiene el cálculo POSIX sin caché.
- Copia anterior: baseline-zig-0.17.tar.gz; hash y metadatos en baseline.json.
- Repetir: python3 scripts/benchmark.py --runs 3 --mode fast

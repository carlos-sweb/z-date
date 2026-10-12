# Changelog

## 0.1.0 — 2026-10-12

Published release with Zig 0.17 support and the retained performance improvements.
Earlier headings below describe development history rather than published GitHub releases.

### Documentation
- Publish the generated Zig API reference to GitHub Pages.
- Update English installation, ownership, error and compatibility documentation.
- Regenerate and deploy documentation automatically after pushes to master.

### Performance candidates and A/B verification
- Preserve the migrated implementation in a SHA-256-verified source archive.
- Extract weekdays/time fields directly; use Gregorian cycles and accumulated
  month lengths for calendar conversion and normalization.
- Reconstruct time setters without decomposing calendar dates.
- Render combined localized strings with one conversion and one allocation,
  with an exact-size fallback for arbitrary custom patterns and labels.
- Reuse POSIX transitions in a bounded thread-local cache; keep WASM uncached.
- Trim parser input once and skip impossible ISO attempts for alphabetic input.
- Add six baseline-equivalence tests (310 total), including complete calendar
  cycles, all locales, DST, extreme components and concurrent cache use.
- Add reproducible paired benchmarks with raw data, allocation counts and medians.

### Zig 0.17 migration
- Require Zig 0.17.0 and update the English/Spanish usage documentation.
- Migrate locale reflection to `decl_names`, allocating formatting to
  `Allocator.print`, and target detection to `builtin.target.os`.
- Keep the public API and date algorithms unchanged.
- Validate all 304 tests in debug, safe, fast, and small modes, plus API
  documentation generation, on Zig 0.17.0 (Linux x86_64).

## Development snapshot 0.2.0 — 2026-07-10

Full ECMA-262 §21.4 conformance, verified against V8. Summary of the jump
from 0.1.0 (160 tests → 303, all green):

### Conformance
- **Strict ISO 8601 parser** (§21.4.3.2): positional grammar that consumes the
  whole input, extended ±YYYYYY years, ±HH:mm offsets, hour-24 rule; date-only
  forms are UTC, date-time without offset is local time.
- **Constructor normalization** (MakeDay/MakeTime/MakeFullYear): overflowing
  components roll over instead of being rejected; two-digit years map to 1900–1999.
- **Safe setters**: Invalid Date stays invalid through every setter; all
  results TimeClip-clamped.
- **NaN semantics**: component getters return `?i32` (`null` ≡ JS `NaN`);
  `equals`/`before`/`after` are false and `compare`/`diff*` are `null` when an
  Invalid Date is involved; `toJSON` returns `null` instead of erroring.
- **Annex B**: `getYear`, `setYear`, `toGMTString` (one documented deviation:
  `setYear` does not resurrect an Invalid Date).
- **`Date.parse` legacy grammar at V8 parity**: month names, AM/PM, times
  without seconds, `2024/01/15`, ISO-with-space, bare ±HHMM offsets,
  parenthesized zone names — with V8's local-time semantics.
- **toISOString expanded years**: signed 6-digit form outside [0, 9999],
  exact at ±8.64e15.

### Timezones (new)
- Real IANA tzdata via `std.Tz` (RFC 8536): system zone on Linux/macOS
  (TZ env, `/etc/localtime`), Windows via `GetDynamicTimeZoneInformation` +
  CLDR mapping, and 599 embeddable zones for WASM/embedded (lazily compiled —
  one zone ≈ 2 KB, full database ≈ 1.4 MB, opt-in).
- Historic DST transitions, POSIX TZ footer rules for dates beyond the
  transition table (full ±275,760-year range), and the spec's local→UTC
  disambiguation at DST transitions (tc39/ecma262#778).
- `getTimezoneOffset` is now per-date (`?i32`, changes across DST).

### Locales (new)
- 145 locales ported from Day.js, one lazily-compiled file each.
- Numeric and long date styles (`toLocaleDateStringStyle`); long style output
  matches `Intl.DateTimeFormat`'s `dateStyle: "long"` (verified against V8
  for en/es/ja/fr/de/ru).

### Hardening
- Integer-overflow panics and a normalization-loop DoS eliminated from
  calendar arithmetic (saturating math + O(1) day normalization).
- Weekday computation fixed for negative (BCE) years — found by the
  differential suite.
- Out-of-range timestamps (public-field bypass) now report Invalid Date
  consistently across all getters and formatters.
- Parser fuzzing: 2,500 mutated/random inputs, no panics.

### Validation
- `tests/v8_differential_test.zig`: 150 random timestamps across the full
  range, ten assertions each, expected values captured from real V8 output;
  plus DST-transition and POSIX-rule edge cases.
- `tests/test262_port_test.zig`: ports of official test262 cases.
- Conformance matrix in the README.

## Initial development snapshot

Initial implementation: ECMAScript Date API surface for Zig 0.15/0.16, 160 tests.

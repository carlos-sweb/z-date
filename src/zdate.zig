//! Z-Date 0.1.0: JavaScript-style dates for Zig 0.17.
//!
//! `ZDate` stores an eight-byte UTC millisecond timestamp. Component getters
//! return `null` for Invalid Date; constructors return a value even on invalid
//! input. Use `fromTimestamp`, `fromComponentsUTC` or `fromISO8601` to construct
//! dates and `isValid` to check them.
//!
//! ## Ownership and local time
//!
//! Formatting returns caller-owned slices: free each result with the allocator
//! passed to that method. `toJSON` can return `null` instead of a slice.
//! Configure the process-wide timezone once before concurrent use; otherwise
//! local time equals UTC. Timezone installation transfers ownership, and
//! `clearLocalTimezone` releases it. POSIX offset lookup has one cache entry per
//! thread; WASM uses the uncached calculation.
//!
//! ## Example
//!
//! ```zig
//! const std = @import("std");
//! const zdate = @import("zdate");
//!
//! pub fn main(init: std.process.Init) !void {
//!     const date = zdate.ZDate.fromISO8601("2024-02-29T12:30:00.000Z");
//!     const text = try date.toISOString(init.gpa);
//!     defer init.gpa.free(text);
//!     std.debug.print("{s}\n", .{text});
//! }
//! ```
//!
//! ## Compatibility
//!
//! UTC ISO formatting handles expanded years and the full TimeClip range.
//! Local `toString`/`toTimeString` currently print a literal `GMT+0000` suffix,
//! even with a non-UTC zone. Scaled arithmetic durations must fit `i64` before
//! addition. See the README for the conformance matrix and current limitations.

const std = @import("std");
const constants = @import("constants.zig");
const errors = @import("errors.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");
const getters = @import("getters.zig");
const setters = @import("setters.zig");
const formatting = @import("formatting.zig");
const parsing = @import("parsing.zig");
const arithmetic = @import("arithmetic.zig");
const localeMod = @import("locale.zig");
const tzdata = @import("tzdata.zig");

/// TimeClip bounds and millisecond conversion constants.
pub const Constants = constants.Constants;
/// Date parsing, range and arithmetic errors.
pub const ZDateError = errors.ZDateError;
/// Select UTC arithmetic or the configured process-wide local timezone.
pub const TimezoneMode = timezone.TimezoneMode;
/// Gregorian date fields; months are zero-based and days are one-based.
pub const DateComponents = calendar.DateComponents;
/// Locale names, numeric order, clock style and long-format pattern.
pub const Locale = localeMod.Locale;
/// Owned TZif data with historical transitions and optional POSIX rules.
pub const Timezone = tzdata.Timezone;
/// Allocation-free POSIX timezone rules for extrapolating UTC offsets.
pub const PosixTz = tzdata.PosixTz;
/// Numeric or long localized date rendering.
pub const DateStyle = formatting.FormattingMethods.DateStyle;

/// Embedded IANA tzdata (for hosts without system tzdata: Windows, WASM,
/// embedded targets). Each zone is an individual lazy declaration - a program
/// that references only `zones.america_santiago` embeds only that file; the
/// name-based `zones.find` (and ZDate.loadEmbeddedTimezone) embeds the full
/// database. Regenerate with scripts/update_tzdata.py.
pub const zones = @import("zones.zig");

/// Windows time zone key name -> IANA zone mapping (CLDR windowsZones data).
/// Used automatically by loadSystemTimezone on Windows; exposed for callers
/// that obtain a Windows zone name through other means.
pub const windows_zones = @import("windows_zones.zig");

/// Built-in locales. Each is its own top-level declaration importing its own
/// file — deliberately not an array or map — so that referencing one locale
/// (e.g. `locales.es_cl`) does not pull the others into the build via Zig's
/// lazy per-declaration analysis.
pub const locales = struct {
    pub const af = @import("locales/af.zig").locale;
    pub const am = @import("locales/am.zig").locale;
    pub const ar = @import("locales/ar.zig").locale;
    pub const ar_dz = @import("locales/ar_dz.zig").locale;
    pub const ar_iq = @import("locales/ar_iq.zig").locale;
    pub const ar_kw = @import("locales/ar_kw.zig").locale;
    pub const ar_ly = @import("locales/ar_ly.zig").locale;
    pub const ar_ma = @import("locales/ar_ma.zig").locale;
    pub const ar_sa = @import("locales/ar_sa.zig").locale;
    pub const ar_tn = @import("locales/ar_tn.zig").locale;
    pub const az = @import("locales/az.zig").locale;
    pub const be = @import("locales/be.zig").locale;
    pub const bg = @import("locales/bg.zig").locale;
    pub const bi = @import("locales/bi.zig").locale;
    pub const bm = @import("locales/bm.zig").locale;
    pub const bn = @import("locales/bn.zig").locale;
    pub const bn_bd = @import("locales/bn_bd.zig").locale;
    pub const bo = @import("locales/bo.zig").locale;
    pub const br = @import("locales/br.zig").locale;
    pub const bs = @import("locales/bs.zig").locale;
    pub const ca = @import("locales/ca.zig").locale;
    pub const cs = @import("locales/cs.zig").locale;
    pub const cv = @import("locales/cv.zig").locale;
    pub const cy = @import("locales/cy.zig").locale;
    pub const da = @import("locales/da.zig").locale;
    pub const de = @import("locales/de.zig").locale;
    pub const de_at = @import("locales/de_at.zig").locale;
    pub const de_ch = @import("locales/de_ch.zig").locale;
    pub const dv = @import("locales/dv.zig").locale;
    pub const el = @import("locales/el.zig").locale;
    pub const en = @import("locales/en.zig").locale;
    pub const en_au = @import("locales/en_au.zig").locale;
    pub const en_ca = @import("locales/en_ca.zig").locale;
    pub const en_gb = @import("locales/en_gb.zig").locale;
    pub const en_ie = @import("locales/en_ie.zig").locale;
    pub const en_il = @import("locales/en_il.zig").locale;
    pub const en_in = @import("locales/en_in.zig").locale;
    pub const en_nz = @import("locales/en_nz.zig").locale;
    pub const en_sg = @import("locales/en_sg.zig").locale;
    pub const en_tt = @import("locales/en_tt.zig").locale;
    pub const en_us = @import("locales/en_us.zig").locale;
    pub const eo = @import("locales/eo.zig").locale;
    pub const es = @import("locales/es.zig").locale;
    pub const es_cl = @import("locales/es_cl.zig").locale;
    pub const es_do = @import("locales/es_do.zig").locale;
    pub const es_mx = @import("locales/es_mx.zig").locale;
    pub const es_pr = @import("locales/es_pr.zig").locale;
    pub const es_us = @import("locales/es_us.zig").locale;
    pub const et = @import("locales/et.zig").locale;
    pub const eu = @import("locales/eu.zig").locale;
    pub const fa = @import("locales/fa.zig").locale;
    pub const fi = @import("locales/fi.zig").locale;
    pub const fo = @import("locales/fo.zig").locale;
    pub const fr = @import("locales/fr.zig").locale;
    pub const fr_ca = @import("locales/fr_ca.zig").locale;
    pub const fr_ch = @import("locales/fr_ch.zig").locale;
    pub const fy = @import("locales/fy.zig").locale;
    pub const ga = @import("locales/ga.zig").locale;
    pub const gd = @import("locales/gd.zig").locale;
    pub const gl = @import("locales/gl.zig").locale;
    pub const gom_latn = @import("locales/gom_latn.zig").locale;
    pub const gu = @import("locales/gu.zig").locale;
    pub const he = @import("locales/he.zig").locale;
    pub const hi = @import("locales/hi.zig").locale;
    pub const hr = @import("locales/hr.zig").locale;
    pub const ht = @import("locales/ht.zig").locale;
    pub const hu = @import("locales/hu.zig").locale;
    pub const hy_am = @import("locales/hy_am.zig").locale;
    pub const id = @import("locales/id.zig").locale;
    pub const is = @import("locales/is.zig").locale;
    pub const it = @import("locales/it.zig").locale;
    pub const it_ch = @import("locales/it_ch.zig").locale;
    pub const ja = @import("locales/ja.zig").locale;
    pub const jv = @import("locales/jv.zig").locale;
    pub const ka = @import("locales/ka.zig").locale;
    pub const kk = @import("locales/kk.zig").locale;
    pub const km = @import("locales/km.zig").locale;
    pub const kn = @import("locales/kn.zig").locale;
    pub const ko = @import("locales/ko.zig").locale;
    pub const ku = @import("locales/ku.zig").locale;
    pub const ky = @import("locales/ky.zig").locale;
    pub const lb = @import("locales/lb.zig").locale;
    pub const lo = @import("locales/lo.zig").locale;
    pub const lt = @import("locales/lt.zig").locale;
    pub const lv = @import("locales/lv.zig").locale;
    pub const me = @import("locales/me.zig").locale;
    pub const mi = @import("locales/mi.zig").locale;
    pub const mk = @import("locales/mk.zig").locale;
    pub const ml = @import("locales/ml.zig").locale;
    pub const mn = @import("locales/mn.zig").locale;
    pub const mr = @import("locales/mr.zig").locale;
    pub const ms = @import("locales/ms.zig").locale;
    pub const ms_my = @import("locales/ms_my.zig").locale;
    pub const mt = @import("locales/mt.zig").locale;
    pub const my = @import("locales/my.zig").locale;
    pub const nb = @import("locales/nb.zig").locale;
    pub const ne = @import("locales/ne.zig").locale;
    pub const nl = @import("locales/nl.zig").locale;
    pub const nl_be = @import("locales/nl_be.zig").locale;
    pub const nn = @import("locales/nn.zig").locale;
    pub const oc_lnc = @import("locales/oc_lnc.zig").locale;
    pub const pa_in = @import("locales/pa_in.zig").locale;
    pub const pl = @import("locales/pl.zig").locale;
    pub const pt = @import("locales/pt.zig").locale;
    pub const pt_br = @import("locales/pt_br.zig").locale;
    pub const rn = @import("locales/rn.zig").locale;
    pub const ro = @import("locales/ro.zig").locale;
    pub const ru = @import("locales/ru.zig").locale;
    pub const rw = @import("locales/rw.zig").locale;
    pub const sd = @import("locales/sd.zig").locale;
    pub const se = @import("locales/se.zig").locale;
    pub const si = @import("locales/si.zig").locale;
    pub const sk = @import("locales/sk.zig").locale;
    pub const sl = @import("locales/sl.zig").locale;
    pub const sq = @import("locales/sq.zig").locale;
    pub const sr = @import("locales/sr.zig").locale;
    pub const sr_cyrl = @import("locales/sr_cyrl.zig").locale;
    pub const ss = @import("locales/ss.zig").locale;
    pub const sv = @import("locales/sv.zig").locale;
    pub const sv_fi = @import("locales/sv_fi.zig").locale;
    pub const sw = @import("locales/sw.zig").locale;
    pub const ta = @import("locales/ta.zig").locale;
    pub const te = @import("locales/te.zig").locale;
    pub const tet = @import("locales/tet.zig").locale;
    pub const tg = @import("locales/tg.zig").locale;
    pub const th = @import("locales/th.zig").locale;
    pub const tk = @import("locales/tk.zig").locale;
    pub const tl_ph = @import("locales/tl_ph.zig").locale;
    pub const tlh = @import("locales/tlh.zig").locale;
    pub const tr = @import("locales/tr.zig").locale;
    pub const tzl = @import("locales/tzl.zig").locale;
    pub const tzm = @import("locales/tzm.zig").locale;
    pub const tzm_latn = @import("locales/tzm_latn.zig").locale;
    pub const ug_cn = @import("locales/ug_cn.zig").locale;
    pub const uk = @import("locales/uk.zig").locale;
    pub const ur = @import("locales/ur.zig").locale;
    pub const uz = @import("locales/uz.zig").locale;
    pub const uz_latn = @import("locales/uz_latn.zig").locale;
    pub const vi = @import("locales/vi.zig").locale;
    pub const x_pseudo = @import("locales/x_pseudo.zig").locale;
    pub const yo = @import("locales/yo.zig").locale;
    pub const zh = @import("locales/zh.zig").locale;
    pub const zh_cn = @import("locales/zh_cn.zig").locale;
    pub const zh_hk = @import("locales/zh_hk.zig").locale;
    pub const zh_tw = @import("locales/zh_tw.zig").locale;
};

const TimezoneUtils = timezone.TimezoneUtils;
const CalendarUtils = calendar.CalendarUtils;
const GetterMethods = getters.GetterMethods;
const SetterMethods = setters.SetterMethods;
const FormattingMethods = formatting.FormattingMethods;
const ParsingMethods = parsing.ParsingMethods;
const ArithmeticMethods = arithmetic.ArithmeticMethods;

const Allocator = std.mem.Allocator;

/// Z-Date: ECMAScript-compatible date/time library for Zig
/// Provides the JavaScript Date API surface with the documented limitations.
///
/// Invalid Date: ECMAScript represents an invalid date as a Date whose internal
/// [[DateValue]] is NaN. ZDate has no floating-point state, so INVALID_TIME
/// (i64 max) is used as the internal sentinel instead, and every component
/// getter (getFullYear, getMonth, getDate, getDay, getHours, getMinutes,
/// getSeconds, getMilliseconds, and their getUTC* counterparts) returns `null`
/// in that case — `null` is this library's NaN.
pub const ZDate = struct {
    /// Timestamp in milliseconds since Unix epoch (January 1, 1970, 00:00:00 UTC)
    /// ZDate is a pure 8-byte value — allocator and io are passed per-function, not stored.
    timestamp: i64,

    const Self = @This();

    // ===== Constructors =====

    /// Initialize with current date/time
    /// Requires io context from std.process.Init (Zig 0.17+)
    pub fn now(io: std.Io) Self {
        return fromTimestamp(nowTimestamp(io));
    }

    /// Initialize from timestamp (milliseconds)
    pub fn fromTimestamp(ms: i64) Self {
        const validated_timestamp: i64 = if (ms < Constants.MIN_TIME or ms > Constants.MAX_TIME)
            Constants.INVALID_TIME
        else
            ms;
        return .{ .timestamp = validated_timestamp };
    }

    /// MakeFullYear: two-digit years 0-99 map to 1900-1999 (ECMA-262 §21.4.3.1 legacy behavior)
    fn makeFullYear(year: i32) i32 {
        if (year >= 0 and year <= 99) return 1900 + year;
        return year;
    }

    /// Initialize from components (year, month, day, etc.)
    /// Overflowing/underflowing fields are normalized (e.g. month 13 rolls into the next year)
    /// rather than rejected, matching the Date constructor / MakeDay semantics.
    pub fn fromComponents(
        year: i32,
        month: i32,
        day: ?i32,
        hour: ?i32,
        minute: ?i32,
        second: ?i32,
        millisecond: ?i32,
    ) Self {
        var components = DateComponents{
            .year = makeFullYear(year),
            .month = month,
            .day = day orelse 1,
            .hour = hour orelse 0,
            .minute = minute orelse 0,
            .second = second orelse 0,
            .millisecond = millisecond orelse 0,
        };

        CalendarUtils.normalizeComponents(&components);

        const timestamp = CalendarUtils.componentsToTimestamp(components, .local);
        return fromTimestamp(timestamp);
    }

    /// Initialize from components (UTC)
    /// See fromComponents() for overflow/underflow normalization semantics.
    pub fn fromComponentsUTC(
        year: i32,
        month: i32,
        day: ?i32,
        hour: ?i32,
        minute: ?i32,
        second: ?i32,
        millisecond: ?i32,
    ) Self {
        var components = DateComponents{
            .year = makeFullYear(year),
            .month = month,
            .day = day orelse 1,
            .hour = hour orelse 0,
            .minute = minute orelse 0,
            .second = second orelse 0,
            .millisecond = millisecond orelse 0,
        };

        CalendarUtils.normalizeComponents(&components);

        const timestamp = CalendarUtils.componentsToTimestamp(components, .utc);
        return fromTimestamp(timestamp);
    }

    /// Initialize from ISO 8601 string
    pub fn fromISO8601(str: []const u8) Self {
        const timestamp = ParsingMethods.parseISO8601(str) catch Constants.INVALID_TIME;
        return fromTimestamp(timestamp);
    }

    /// Initialize from date string (various formats)
    pub fn fromString(str: []const u8) Self {
        return fromTimestamp(ParsingMethods.parse(str));
    }

    // ===== Static Methods (Date.*) =====

    /// Date.now() - Get current timestamp in milliseconds
    /// Requires io context from std.process.Init (Zig 0.17+)
    pub fn nowTimestamp(io: std.Io) i64 {
        const t = std.Io.Clock.real.now(io);
        return t.toMilliseconds();
    }

    // ===== Local timezone (host environment) =====
    //
    // ECMA-262 models the local timezone as belonging to the host
    // environment, not to each Date value; these functions configure that
    // process-wide zone. Until one of them is called, the local offset is 0
    // (local == UTC), which the spec explicitly permits for hosts without
    // timezone data. Load once at startup, before concurrent ZDate use.

    /// Load the host system's timezone (the TZ environment variable when
    /// `environ` is provided, then /etc/localtime) as the local zone.
    pub fn loadSystemTimezone(allocator: Allocator, io: std.Io, environ: ?std.process.Environ) !void {
        return TimezoneUtils.loadSystemTimezone(allocator, io, environ);
    }

    /// Load a named IANA zone (e.g. "America/Santiago") from the system
    /// tzdata directory as the local zone.
    pub fn loadNamedTimezone(allocator: Allocator, io: std.Io, name: []const u8) !void {
        return TimezoneUtils.loadNamedTimezone(allocator, io, name);
    }

    /// Install an already-loaded Timezone as the local zone, taking
    /// ownership (e.g. one built with Timezone.parseBytes from embedded
    /// TZif data).
    pub fn setLocalTimezone(tz: Timezone) void {
        TimezoneUtils.setLocalTimezone(tz);
    }

    /// Load a named IANA zone from the EMBEDDED tzdata as the local zone,
    /// for hosts without system tzdata (Windows, WASM, embedded targets).
    ///
    /// Calling this embeds the full IANA database (~1.4 MB) in the binary;
    /// to embed a single zone instead, reference it directly:
    ///   ZDate.setLocalTimezone(try Timezone.parseBytes(alloc, zones.america_santiago));
    pub fn loadEmbeddedTimezone(allocator: Allocator, name: []const u8) !void {
        const data = zones.find(name) orelse return error.UnknownTimezone;
        const tz = try Timezone.parseBytes(allocator, data);
        TimezoneUtils.setLocalTimezone(tz);
    }

    /// Release the local timezone and return to the no-data default
    /// (offset 0, local == UTC).
    pub fn clearLocalTimezone() void {
        TimezoneUtils.clearLocalTimezone();
    }

    /// Date.parse() - Parse date string to timestamp
    pub fn parse(str: []const u8) i64 {
        return ParsingMethods.parse(str);
    }

    /// Date.UTC() - Get UTC timestamp from components
    /// See fromComponents() for overflow/underflow normalization semantics.
    pub fn UTC(
        year: i32,
        month: i32,
        day: ?i32,
        hour: ?i32,
        minute: ?i32,
        second: ?i32,
        millisecond: ?i32,
    ) i64 {
        var components = DateComponents{
            .year = makeFullYear(year),
            .month = month,
            .day = day orelse 1,
            .hour = hour orelse 0,
            .minute = minute orelse 0,
            .second = second orelse 0,
            .millisecond = millisecond orelse 0,
        };

        CalendarUtils.normalizeComponents(&components);

        const timestamp = CalendarUtils.componentsToTimestamp(components, .utc);
        if (timestamp < Constants.MIN_TIME or timestamp > Constants.MAX_TIME) {
            return Constants.INVALID_TIME;
        }
        return timestamp;
    }

    // ===== Getters (Local Time) =====

    /// getFullYear() - Get 4-digit year (local time). Returns null for Invalid Date.
    pub fn getFullYear(self: Self) ?i32 {
        return GetterMethods.getFullYear(self.timestamp, .local);
    }

    /// getMonth() - Get month (0-11, local time). Returns null for Invalid Date.
    pub fn getMonth(self: Self) ?i32 {
        return GetterMethods.getMonth(self.timestamp, .local);
    }

    /// getDate() - Get day of month (1-31, local time). Returns null for Invalid Date.
    pub fn getDate(self: Self) ?i32 {
        return GetterMethods.getDate(self.timestamp, .local);
    }

    /// getDay() - Get day of week (0-6, Sunday=0, local time). Returns null for Invalid Date.
    pub fn getDay(self: Self) ?i32 {
        return GetterMethods.getDay(self.timestamp, .local);
    }

    /// getHours() - Get hours (0-23, local time). Returns null for Invalid Date.
    pub fn getHours(self: Self) ?i32 {
        return GetterMethods.getHours(self.timestamp, .local);
    }

    /// getMinutes() - Get minutes (0-59, local time). Returns null for Invalid Date.
    pub fn getMinutes(self: Self) ?i32 {
        return GetterMethods.getMinutes(self.timestamp, .local);
    }

    /// getSeconds() - Get seconds (0-59, local time). Returns null for Invalid Date.
    pub fn getSeconds(self: Self) ?i32 {
        return GetterMethods.getSeconds(self.timestamp, .local);
    }

    /// getMilliseconds() - Get milliseconds (0-999, local time). Returns null for Invalid Date.
    pub fn getMilliseconds(self: Self) ?i32 {
        return GetterMethods.getMilliseconds(self.timestamp, .local);
    }

    /// getTime() - Get timestamp
    pub fn getTime(self: Self) i64 {
        return GetterMethods.getTime(self.timestamp);
    }

    /// getTimezoneOffset() - Get timezone offset in minutes (UTC - local) in
    /// effect at this date. Returns null for Invalid Date (JS returns NaN).
    pub fn getTimezoneOffset(self: Self) ?i32 {
        return GetterMethods.getTimezoneOffset(self.timestamp);
    }

    /// getYear() - Legacy (ECMA-262 Annex B.2.3): full year minus 1900, local
    /// time. Returns null for Invalid Date. Superseded by getFullYear().
    pub fn getYear(self: Self) ?i32 {
        return GetterMethods.getYear(self.timestamp, .local);
    }

    // ===== Getters (UTC) =====

    /// getUTCFullYear() - Get 4-digit year (UTC). Returns null for Invalid Date.
    pub fn getUTCFullYear(self: Self) ?i32 {
        return GetterMethods.getFullYear(self.timestamp, .utc);
    }

    /// getUTCMonth() - Get month (0-11, UTC). Returns null for Invalid Date.
    pub fn getUTCMonth(self: Self) ?i32 {
        return GetterMethods.getMonth(self.timestamp, .utc);
    }

    /// getUTCDate() - Get day of month (1-31, UTC). Returns null for Invalid Date.
    pub fn getUTCDate(self: Self) ?i32 {
        return GetterMethods.getDate(self.timestamp, .utc);
    }

    /// getUTCDay() - Get day of week (0-6, Sunday=0, UTC). Returns null for Invalid Date.
    pub fn getUTCDay(self: Self) ?i32 {
        return GetterMethods.getDay(self.timestamp, .utc);
    }

    /// getUTCHours() - Get hours (0-23, UTC). Returns null for Invalid Date.
    pub fn getUTCHours(self: Self) ?i32 {
        return GetterMethods.getHours(self.timestamp, .utc);
    }

    /// getUTCMinutes() - Get minutes (0-59, UTC). Returns null for Invalid Date.
    pub fn getUTCMinutes(self: Self) ?i32 {
        return GetterMethods.getMinutes(self.timestamp, .utc);
    }

    /// getUTCSeconds() - Get seconds (0-59, UTC). Returns null for Invalid Date.
    pub fn getUTCSeconds(self: Self) ?i32 {
        return GetterMethods.getSeconds(self.timestamp, .utc);
    }

    /// getUTCMilliseconds() - Get milliseconds (0-999, UTC). Returns null for Invalid Date.
    pub fn getUTCMilliseconds(self: Self) ?i32 {
        return GetterMethods.getMilliseconds(self.timestamp, .utc);
    }

    // ===== Setters (Local Time) =====

    /// setFullYear() - Set year (local time). Invalid Date uses epoch as its base.
    pub fn setFullYear(self: *Self, year: i32, month: ?i32, day: ?i32) i64 {
        return SetterMethods.setFullYear(&self.timestamp, year, month, day, .local);
    }

    /// setMonth() - Set month (local time)
    pub fn setMonth(self: *Self, month: i32, day: ?i32) i64 {
        return SetterMethods.setMonth(&self.timestamp, month, day, .local);
    }

    /// setDate() - Set day of month (local time)
    pub fn setDate(self: *Self, day: i32) i64 {
        return SetterMethods.setDate(&self.timestamp, day, .local);
    }

    /// setHours() - Set hours (local time)
    pub fn setHours(self: *Self, hour: i32, min: ?i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setHours(&self.timestamp, hour, min, sec, ms, .local);
    }

    /// setMinutes() - Set minutes (local time)
    pub fn setMinutes(self: *Self, min: i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setMinutes(&self.timestamp, min, sec, ms, .local);
    }

    /// setSeconds() - Set seconds (local time)
    pub fn setSeconds(self: *Self, sec: i32, ms: ?i32) i64 {
        return SetterMethods.setSeconds(&self.timestamp, sec, ms, .local);
    }

    /// setMilliseconds() - Set milliseconds (local time)
    pub fn setMilliseconds(self: *Self, ms: i32) i64 {
        return SetterMethods.setMilliseconds(&self.timestamp, ms, .local);
    }

    /// setTime() - Set timestamp
    pub fn setTime(self: *Self, timestamp: i64) i64 {
        return SetterMethods.setTime(&self.timestamp, timestamp);
    }

    /// setYear() - Legacy (ECMA-262 Annex B.2.3): two-digit years (0-99) map
    /// to 1900-1999, local time. Repairs Invalid Date using an epoch base.
    /// Superseded by setFullYear().
    pub fn setYear(self: *Self, year: i32) i64 {
        return SetterMethods.setYear(&self.timestamp, year, .local);
    }

    // ===== Setters (UTC) =====

    /// setUTCFullYear() - Set year (UTC). Invalid Date uses epoch as its base.
    pub fn setUTCFullYear(self: *Self, year: i32, month: ?i32, day: ?i32) i64 {
        return SetterMethods.setFullYear(&self.timestamp, year, month, day, .utc);
    }

    /// setUTCMonth() - Set month (UTC)
    pub fn setUTCMonth(self: *Self, month: i32, day: ?i32) i64 {
        return SetterMethods.setMonth(&self.timestamp, month, day, .utc);
    }

    /// setUTCDate() - Set day of month (UTC)
    pub fn setUTCDate(self: *Self, day: i32) i64 {
        return SetterMethods.setDate(&self.timestamp, day, .utc);
    }

    /// setUTCHours() - Set hours (UTC)
    pub fn setUTCHours(self: *Self, hour: i32, min: ?i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setHours(&self.timestamp, hour, min, sec, ms, .utc);
    }

    /// setUTCMinutes() - Set minutes (UTC)
    pub fn setUTCMinutes(self: *Self, min: i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setMinutes(&self.timestamp, min, sec, ms, .utc);
    }

    /// setUTCSeconds() - Set seconds (UTC)
    pub fn setUTCSeconds(self: *Self, sec: i32, ms: ?i32) i64 {
        return SetterMethods.setSeconds(&self.timestamp, sec, ms, .utc);
    }

    /// setUTCMilliseconds() - Set milliseconds (UTC)
    pub fn setUTCMilliseconds(self: *Self, ms: i32) i64 {
        return SetterMethods.setMilliseconds(&self.timestamp, ms, .utc);
    }

    // ===== Formatting Methods =====

    /// toString() - Convert to string (local time)
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toString(self.timestamp, allocator);
    }

    /// toDateString() - Date portion only
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toDateString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toDateString(self.timestamp, allocator);
    }

    /// toTimeString() - Time portion only
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toTimeString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toTimeString(self.timestamp, allocator);
    }

    /// toISOString() - ISO 8601 format (UTC)
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    /// Returns `InvalidDate` for the invalid sentinel or `OutOfRange` outside TimeClip.
    pub fn toISOString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toISOString(self.timestamp, allocator);
    }

    /// toJSON() - JSON representation. Returns null (JSON `null`) for Invalid
    /// Date rather than erroring, per ECMA-262 Date.prototype.toJSON.
    /// A non-null result is allocator-owned and must be freed. May return `OutOfMemory`.
    pub fn toJSON(self: Self, allocator: Allocator) !?[]u8 {
        return FormattingMethods.toJSON(self.timestamp, allocator);
    }

    /// toUTCString() - UTC string
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toUTCString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toUTCString(self.timestamp, allocator);
    }

    /// toGMTString() - Legacy alias for toUTCString(); prefer toUTCString() in new code.
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toGMTString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toGMTString(self.timestamp, allocator);
    }

    /// toLocaleDateString() - Localized date string. `null` locale defaults to en-US.
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toLocaleDateString(self: Self, allocator: Allocator, locale: ?Locale) ![]u8 {
        return FormattingMethods.toLocaleDateString(self.timestamp, allocator, locale);
    }

    /// toLocaleTimeString() - Localized time string. `null` locale defaults to en-US.
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toLocaleTimeString(self: Self, allocator: Allocator, locale: ?Locale) ![]u8 {
        return FormattingMethods.toLocaleTimeString(self.timestamp, allocator, locale);
    }

    /// toLocaleString() - Localized date and time string. `null` locale defaults to en-US.
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toLocaleString(self: Self, allocator: Allocator, locale: ?Locale) ![]u8 {
        return FormattingMethods.toLocaleString(self.timestamp, allocator, locale);
    }

    /// toLocaleDateString with an explicit style, mirroring
    /// Intl.DateTimeFormat's dateStyle: .numeric ("01/15/2024") or .long
    /// ("January 15, 2024" / "15 de enero de 2024" / "2024年1月15日").
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toLocaleDateStringStyle(self: Self, allocator: Allocator, locale: ?Locale, style: DateStyle) ![]u8 {
        return FormattingMethods.toLocaleDateStringStyle(self.timestamp, allocator, locale, style);
    }

    /// toLocaleString with an explicit date style (see toLocaleDateStringStyle).
    /// Returns allocator-owned text; the caller must free it. May return `OutOfMemory`.
    pub fn toLocaleStringStyle(self: Self, allocator: Allocator, locale: ?Locale, style: DateStyle) ![]u8 {
        return FormattingMethods.toLocaleStringStyle(self.timestamp, allocator, locale, style);
    }

    /// valueOf() - Return timestamp
    pub fn valueOf(self: Self) i64 {
        return self.timestamp;
    }

    // ===== Comparison and Arithmetic =====

    /// Check if two dates are equal. Always false if either is Invalid Date
    /// (matching `NaN === NaN` being false in JS).
    pub fn equals(self: Self, other: Self) bool {
        return ArithmeticMethods.equals(self.timestamp, other.timestamp);
    }

    /// Check if this date is before another. Always false if either is Invalid Date.
    pub fn before(self: Self, other: Self) bool {
        return ArithmeticMethods.before(self.timestamp, other.timestamp);
    }

    /// Check if this date is after another. Always false if either is Invalid Date.
    pub fn after(self: Self, other: Self) bool {
        return ArithmeticMethods.after(self.timestamp, other.timestamp);
    }

    /// Compare with another date. Returns null if either is Invalid Date:
    /// no lt/eq/gt relationship holds when NaN is involved.
    pub fn compare(self: Self, other: Self) ?std.math.Order {
        return ArithmeticMethods.compare(self.timestamp, other.timestamp);
    }

    /// Add milliseconds
    /// Returns a new date, leaving this value unchanged. May return `OutOfRange` or
    /// `TimestampOverflow` from the checked millisecond addition.
    pub fn addMilliseconds(self: Self, ms: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addMilliseconds(self.timestamp, ms);
        return fromTimestamp(new_timestamp);
    }

    /// Add seconds
    /// Returns a new date, leaving this value unchanged. May return `OutOfRange` or
    /// `TimestampOverflow` from the checked millisecond addition.
    /// The seconds argument scaled to milliseconds must fit `i64`.
    pub fn addSeconds(self: Self, seconds: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addSeconds(self.timestamp, seconds);
        return fromTimestamp(new_timestamp);
    }

    /// Add minutes
    /// Returns a new date, leaving this value unchanged. May return `OutOfRange` or
    /// `TimestampOverflow` from the checked millisecond addition.
    /// The minutes argument scaled to milliseconds must fit `i64`.
    pub fn addMinutes(self: Self, minutes: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addMinutes(self.timestamp, minutes);
        return fromTimestamp(new_timestamp);
    }

    /// Add hours
    /// Returns a new date, leaving this value unchanged. May return `OutOfRange` or
    /// `TimestampOverflow` from the checked millisecond addition.
    /// The hours argument scaled to milliseconds must fit `i64`.
    pub fn addHours(self: Self, hours: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addHours(self.timestamp, hours);
        return fromTimestamp(new_timestamp);
    }

    /// Add days
    /// Returns a new date, leaving this value unchanged. May return `OutOfRange` or
    /// `TimestampOverflow` from the checked millisecond addition.
    /// The 24-hour days argument scaled to milliseconds must fit `i64`.
    /// This is a fixed duration, not a DST-aware calendar-day increment.
    pub fn addDays(self: Self, days: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addDays(self.timestamp, days);
        return fromTimestamp(new_timestamp);
    }

    /// Difference in milliseconds. Null if either date is Invalid Date.
    pub fn diffMilliseconds(self: Self, other: Self) ?i64 {
        return ArithmeticMethods.diffMilliseconds(self.timestamp, other.timestamp);
    }

    /// Difference in seconds. Null if either date is Invalid Date.
    pub fn diffSeconds(self: Self, other: Self) ?i64 {
        return ArithmeticMethods.diffSeconds(self.timestamp, other.timestamp);
    }

    /// Difference in minutes. Null if either date is Invalid Date.
    pub fn diffMinutes(self: Self, other: Self) ?i64 {
        return ArithmeticMethods.diffMinutes(self.timestamp, other.timestamp);
    }

    /// Difference in hours. Null if either date is Invalid Date.
    pub fn diffHours(self: Self, other: Self) ?i64 {
        return ArithmeticMethods.diffHours(self.timestamp, other.timestamp);
    }

    /// Difference in days. Null if either date is Invalid Date.
    pub fn diffDays(self: Self, other: Self) ?i64 {
        return ArithmeticMethods.diffDays(self.timestamp, other.timestamp);
    }

    // ===== Validation =====

    /// Check if date is valid
    pub fn isValid(self: Self) bool {
        return self.timestamp != Constants.INVALID_TIME and
            self.timestamp >= Constants.MIN_TIME and
            self.timestamp <= Constants.MAX_TIME;
    }

    /// Check if year is leap year
    pub fn isLeapYear(year: i32) bool {
        return CalendarUtils.isLeapYear(year);
    }
};

// Export all public APIs
/// Low-level Gregorian calculations; normalize fields before converting to timestamps.
pub const CalendarUtil = CalendarUtils;
/// Process-wide local timezone configuration and UTC/local conversion.
pub const TimezoneUtil = TimezoneUtils;

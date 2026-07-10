/// Locale data used by the toLocale*String() formatting methods.
/// A Locale carries no behavior — it is a plain data record consumed by
/// FormattingMethods.toLocaleDateString/toLocaleTimeString/toLocaleString.
pub const Locale = struct {
    month_names: [12][]const u8,
    month_names_short: [12][]const u8,
    day_names: [7][]const u8,
    day_names_short: [7][]const u8,
    date_order: enum { dmy, mdy, ymd },
    date_separator: u8,
    time_24h: bool,
    am_label: []const u8,
    pm_label: []const u8,

    /// Separator between hour/minute/second in time output (':' almost
    /// everywhere; '.' in e.g. Finnish and Danish).
    time_separator: u8 = ':',

    /// Pattern for the "long" date style (Day.js's LL), e.g.
    /// "MMMM D, YYYY" (en), "D de MMMM de YYYY" (es), "YYYY年M月D日" (ja).
    /// Tokens: YYYY (year), MMMM (full month name), MMM (short month name),
    /// MM (2-digit month), M (month), DD (2-digit day), D (day); any other
    /// byte is a literal. Empty (the default) derives a pattern from
    /// date_order: dmy -> "D MMMM YYYY", mdy -> "MMMM D, YYYY",
    /// ymd -> "YYYY MMMM D".
    long_date_format: []const u8 = "",
};

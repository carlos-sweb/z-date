const Locale = @import("../locale.zig").Locale;

/// Klingon locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "tera’ jar wa’",     "tera’ jar cha’",       "tera’ jar wej",
        "tera’ jar loS",     "tera’ jar vagh",       "tera’ jar jav",
        "tera’ jar Soch",    "tera’ jar chorgh",     "tera’ jar Hut",
        "tera’ jar wa’maH",  "tera’ jar wa’maH wa’", "tera’ jar wa’maH cha’",
    },
    .month_names_short = .{
        "jar wa’",    "jar cha’",      "jar wej",
        "jar loS",    "jar vagh",      "jar jav",
        "jar Soch",   "jar chorgh",    "jar Hut",
        "jar wa’maH", "jar wa’maH wa’", "jar wa’maH cha’",
    },
    .day_names = .{
        "lojmItjaj", "DaSjaj",   "povjaj", "ghItlhjaj",
        "loghjaj",   "buqjaj",   "ghInjaj",
    },
    .day_names_short = .{
        "lojmItjaj", "DaSjaj", "povjaj", "ghItlhjaj", "loghjaj", "buqjaj", "ghInjaj",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

const Locale = @import("../locale.zig").Locale;

/// Uyghur (China) locale: YYYY-MM-DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "يانۋار",   "فېۋرال",   "مارت",     "ئاپرېل",
        "ماي",      "ئىيۇن",    "ئىيۇل",    "ئاۋغۇست",
        "سېنتەبىر", "ئۆكتەبىر", "نويابىر",  "دېكابىر",
    },
    .month_names_short = .{
        "يانۋار",   "فېۋرال",   "مارت",     "ئاپرېل",
        "ماي",      "ئىيۇن",    "ئىيۇل",    "ئاۋغۇست",
        "سېنتەبىر", "ئۆكتەبىر", "نويابىر",  "دېكابىر",
    },
    .day_names = .{
        "يەكشەنبە", "دۈشەنبە", "سەيشەنبە", "چارشەنبە",
        "پەيشەنبە", "جۈمە",    "شەنبە",
    },
    .day_names_short = .{
        "يە", "دۈ", "سە", "چا", "پە", "جۈ", "شە",
    },
    .date_order = .ymd,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

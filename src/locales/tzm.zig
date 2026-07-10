const Locale = @import("../locale.zig").Locale;

/// Central Atlas Tamazight (Tifinagh script) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ⵉⵏⵏⴰⵢⵔ",   "ⴱⵕⴰⵢⵕ",     "ⵎⴰⵕⵚ",      "ⵉⴱⵔⵉⵔ",
        "ⵎⴰⵢⵢⵓ",   "ⵢⵓⵏⵢⵓ",     "ⵢⵓⵍⵢⵓⵣ",    "ⵖⵓⵛⵜ",
        "ⵛⵓⵜⴰⵏⴱⵉⵔ", "ⴽⵟⵓⴱⵕ",     "ⵏⵓⵡⴰⵏⴱⵉⵔ",  "ⴷⵓⵊⵏⴱⵉⵔ",
    },
    .month_names_short = .{
        "ⵉⵏⵏⴰⵢⵔ",   "ⴱⵕⴰⵢⵕ",     "ⵎⴰⵕⵚ",      "ⵉⴱⵔⵉⵔ",
        "ⵎⴰⵢⵢⵓ",   "ⵢⵓⵏⵢⵓ",     "ⵢⵓⵍⵢⵓⵣ",    "ⵖⵓⵛⵜ",
        "ⵛⵓⵜⴰⵏⴱⵉⵔ", "ⴽⵟⵓⴱⵕ",     "ⵏⵓⵡⴰⵏⴱⵉⵔ",  "ⴷⵓⵊⵏⴱⵉⵔ",
    },
    .day_names = .{
        "ⴰⵙⴰⵎⴰⵙ", "ⴰⵢⵏⴰⵙ",   "ⴰⵙⵉⵏⴰⵙ", "ⴰⴽⵔⴰⵙ",
        "ⴰⴽⵡⴰⵙ",  "ⴰⵙⵉⵎⵡⴰⵙ", "ⴰⵙⵉⴹⵢⴰⵙ",
    },
    .day_names_short = .{
        "ⴰⵙⴰⵎⴰⵙ", "ⴰⵢⵏⴰⵙ", "ⴰⵙⵉⵏⴰⵙ", "ⴰⴽⵔⴰⵙ", "ⴰⴽⵡⴰⵙ", "ⴰⵙⵉⵎⵡⴰⵙ", "ⴰⵙⵉⴹⵢⴰⵙ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

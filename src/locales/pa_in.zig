const Locale = @import("../locale.zig").Locale;

/// Punjabi (India) locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ਜਨਵਰੀ",   "ਫ਼ਰਵਰੀ",  "ਮਾਰਚ",    "ਅਪ੍ਰੈਲ",
        "ਮਈ",      "ਜੂਨ",     "ਜੁਲਾਈ",   "ਅਗਸਤ",
        "ਸਤੰਬਰ",   "ਅਕਤੂਬਰ", "ਨਵੰਬਰ",   "ਦਸੰਬਰ",
    },
    .month_names_short = .{
        "ਜਨਵਰੀ",   "ਫ਼ਰਵਰੀ",  "ਮਾਰਚ",    "ਅਪ੍ਰੈਲ",
        "ਮਈ",      "ਜੂਨ",     "ਜੁਲਾਈ",   "ਅਗਸਤ",
        "ਸਤੰਬਰ",   "ਅਕਤੂਬਰ", "ਨਵੰਬਰ",   "ਦਸੰਬਰ",
    },
    .day_names = .{
        "ਐਤਵਾਰ",   "ਸੋਮਵਾਰ",  "ਮੰਗਲਵਾਰ", "ਬੁਧਵਾਰ",
        "ਵੀਰਵਾਰ",  "ਸ਼ੁੱਕਰਵਾਰ", "ਸ਼ਨੀਚਰਵਾਰ",
    },
    .day_names_short = .{
        "ਐਤ", "ਸੋਮ", "ਮੰਗਲ", "ਬੁਧ", "ਵੀਰ", "ਸ਼ੁਕਰ", "ਸ਼ਨੀ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

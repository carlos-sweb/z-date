const Locale = @import("../locale.zig").Locale;

/// Persian (Farsi) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ژانویه", "فوریه", "مارس",    "آوریل",
        "مه",     "ژوئن",  "ژوئیه",   "اوت",
        "سپتامبر", "اکتبر", "نوامبر",  "دسامبر",
    },
    .month_names_short = .{
        "ژانویه", "فوریه", "مارس",    "آوریل",
        "مه",     "ژوئن",  "ژوئیه",   "اوت",
        "سپتامبر", "اکتبر", "نوامبر",  "دسامبر",
    },
    .day_names = .{
        "یک‌شنبه",  "دوشنبه",    "سه‌شنبه", "چهارشنبه",
        "پنج‌شنبه", "جمعه",      "شنبه",
    },
    .day_names_short = .{
        "یک‌شنبه",  "دوشنبه",    "سه‌شنبه", "چهارشنبه",
        "پنج‌شنبه", "جمعه",      "شنبه",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

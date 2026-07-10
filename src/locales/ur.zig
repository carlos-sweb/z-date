const Locale = @import("../locale.zig").Locale;

/// Urdu locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "جنوری",  "فروری", "مارچ",   "اپریل",
        "مئی",    "جون",   "جولائی", "اگست",
        "ستمبر",  "اکتوبر", "نومبر",  "دسمبر",
    },
    .month_names_short = .{
        "جنوری",  "فروری", "مارچ",   "اپریل",
        "مئی",    "جون",   "جولائی", "اگست",
        "ستمبر",  "اکتوبر", "نومبر",  "دسمبر",
    },
    .day_names = .{
        "اتوار", "پیر",   "منگل", "بدھ",
        "جمعرات", "جمعہ",  "ہفتہ",
    },
    .day_names_short = .{
        "اتوار", "پیر", "منگل", "بدھ", "جمعرات", "جمعہ", "ہفتہ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

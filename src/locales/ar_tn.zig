const Locale = @import("../locale.zig").Locale;

/// Arabic (Tunisia) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "جانفي",   "فيفري",   "مارس",    "أفريل",
        "ماي",     "جوان",    "جويلية",  "أوت",
        "سبتمبر",  "أكتوبر",  "نوفمبر",  "ديسمبر",
    },
    .month_names_short = .{
        "جانفي",   "فيفري",   "مارس",    "أفريل",
        "ماي",     "جوان",    "جويلية",  "أوت",
        "سبتمبر",  "أكتوبر",  "نوفمبر",  "ديسمبر",
    },
    .day_names = .{
        "الأحد", "الإثنين", "الثلاثاء", "الأربعاء",
        "الخميس", "الجمعة", "السبت",
    },
    .day_names_short = .{
        "أحد", "إثنين", "ثلاثاء", "أربعاء", "خميس", "جمعة", "سبت",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "ص",
    .pm_label = "م",
};

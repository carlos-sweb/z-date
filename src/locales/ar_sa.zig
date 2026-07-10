const Locale = @import("../locale.zig").Locale;

/// Arabic (Saudi Arabia) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "يناير",   "فبراير",  "مارس",    "أبريل",
        "مايو",    "يونيو",   "يوليو",   "أغسطس",
        "سبتمبر",  "أكتوبر",  "نوفمبر",  "ديسمبر",
    },
    .month_names_short = .{
        "يناير",   "فبراير",  "مارس",    "أبريل",
        "مايو",    "يونيو",   "يوليو",   "أغسطس",
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

const Locale = @import("../locale.zig").Locale;

/// Arabic (Kuwait) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "يناير",   "فبراير",  "مارس",   "أبريل",
        "ماي",     "يونيو",   "يوليوز", "غشت",
        "شتنبر",   "أكتوبر",  "نونبر",  "دجنبر",
    },
    .month_names_short = .{
        "يناير",   "فبراير",  "مارس",   "أبريل",
        "ماي",     "يونيو",   "يوليوز", "غشت",
        "شتنبر",   "أكتوبر",  "نونبر",  "دجنبر",
    },
    .day_names = .{
        "الأحد", "الإثنين", "الثلاثاء", "الأربعاء",
        "الخميس", "الجمعة", "السبت",
    },
    .day_names_short = .{
        "احد", "اثنين", "ثلاثاء", "اربعاء", "خميس", "جمعة", "سبت",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "ص",
    .pm_label = "م",
};

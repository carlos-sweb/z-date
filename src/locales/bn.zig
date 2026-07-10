const Locale = @import("../locale.zig").Locale;

/// Bengali locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "জানুয়ারি",  "ফেব্রুয়ারি", "মার্চ",  "এপ্রিল",
        "মে",        "জুন",       "জুলাই", "আগস্ট",
        "সেপ্টেম্বর", "অক্টোবর",   "নভেম্বর", "ডিসেম্বর",
    },
    .month_names_short = .{
        "জানু", "ফেব্রু", "মার্চ", "এপ্রিল", "মে", "জুন",
        "জুলাই", "আগস্ট", "সেপ্ট", "অক্টো", "নভে", "ডিসে",
    },
    .day_names = .{
        "রবিবার", "সোমবার",   "মঙ্গলবার", "বুধবার",
        "বৃহস্পতিবার", "শুক্রবার", "শনিবার",
    },
    .day_names_short = .{
        "রবি", "সোম", "মঙ্গল", "বুধ", "বৃহস্পতি", "শুক্র", "শনি",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

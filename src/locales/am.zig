const Locale = @import("../locale.zig").Locale;

/// Amharic locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ጃንዋሪ", "ፌብሯሪ", "ማርች", "ኤፕሪል",
        "ሜይ",   "ጁን",   "ጁላይ", "ኦገስት",
        "ሴፕቴምበር", "ኦክቶበር", "ኖቬምበር", "ዲሴምበር",
    },
    .month_names_short = .{
        "ጃንዋ", "ፌብሯ", "ማርች", "ኤፕሪ", "ሜይ", "ጁን",
        "ጁላይ", "ኦገስ", "ሴፕቴ", "ኦክቶ", "ኖቬም", "ዲሴም",
    },
    .day_names = .{
        "እሑድ", "ሰኞ",   "ማክሰኞ", "ረቡዕ",
        "ሐሙስ", "አርብ", "ቅዳሜ",
    },
    .day_names_short = .{
        "እሑድ", "ሰኞ", "ማክሰ", "ረቡዕ", "ሐሙስ", "አርብ", "ቅዳሜ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

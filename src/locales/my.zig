const Locale = @import("../locale.zig").Locale;

/// Burmese locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ဇန်နဝါရီ",  "ဖေဖော်ဝါရီ", "မတ်",       "ဧပြီ",
        "မေ",        "ဇွန်",       "ဇူလိုင်",   "သြဂုတ်",
        "စက်တင်ဘာ",  "အောက်တိုဘာ", "နိုဝင်ဘာ",  "ဒီဇင်ဘာ",
    },
    .month_names_short = .{
        "ဇန်", "ဖေ", "မတ်", "ပြီ", "မေ", "ဇွန်",
        "လိုင်", "သြ", "စက်", "အောက်", "နို", "ဒီ",
    },
    .day_names = .{
        "တနင်္ဂနွေ", "တနင်္လာ", "အင်္ဂါ", "ဗုဒ္ဓဟူး",
        "ကြာသပတေး", "သောကြာ", "စနေ",
    },
    .day_names_short = .{
        "နွေ", "လာ", "ဂါ", "ဟူး", "ကြာ", "သော", "နေ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

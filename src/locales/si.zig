const Locale = @import("../locale.zig").Locale;

/// Sinhalese locale: YYYY/MM/DD, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "දුරුතු",  "නවම්",   "මැදින්", "බක්",
        "වෙසක්",  "පොසොන්", "ඇසළ",   "නිකිණි",
        "බිනර",   "වප්",    "ඉල්",   "උඳුවප්",
    },
    .month_names_short = .{
        "දුරු", "නව", "මැදි", "බක්", "වෙස", "පොසො",
        "ඇස", "නිකි", "බින", "වප්", "ඉල්", "උඳු",
    },
    .day_names = .{
        "ඉරිදා",  "සඳුදා",  "අඟහරුවාදා", "බදාදා",
        "බ්‍රහස්පතින්දා", "සිකුරාදා", "සෙනසුරාදා",
    },
    .day_names_short = .{
        "ඉරි", "සඳු", "අඟ", "බදා", "බ්‍රහ", "සිකු", "සෙන",
    },
    .date_order = .ymd,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

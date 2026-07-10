const Locale = @import("../locale.zig").Locale;

/// Gujarati locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "જાન્યુઆરી", "ફેબ્રુઆરી", "માર્ચ",      "એપ્રિલ",
        "મે",        "જૂન",       "જુલાઈ",     "ઑગસ્ટ",
        "સપ્ટેમ્બર", "ઑક્ટ્બર",   "નવેમ્બર",   "ડિસેમ્બર",
    },
    .month_names_short = .{
        "જાન્યુ.", "ફેબ્રુ.", "માર્ચ", "એપ્રિ.",
        "મે",      "જૂન",     "જુલા.", "ઑગ.",
        "સપ્ટે.",  "ઑક્ટ્.",  "નવે.",  "ડિસે.",
    },
    .day_names = .{
        "રવિવાર",  "સોમવાર", "મંગળવાર", "બુધ્વાર",
        "ગુરુવાર", "શુક્રવાર", "શનિવાર",
    },
    .day_names_short = .{
        "રવિ", "સોમ", "મંગળ", "બુધ્", "ગુરુ", "શુક્ર", "શનિ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

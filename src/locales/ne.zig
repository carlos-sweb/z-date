const Locale = @import("../locale.zig").Locale;

/// Nepalese locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "जनवरी",     "फेब्रुवरी", "मार्च",    "अप्रिल",
        "मे",        "जुन",       "जुलाई",    "अगष्ट",
        "सेप्टेम्बर", "अक्टोबर",  "नोभेम्बर", "डिसेम्बर",
    },
    .month_names_short = .{
        "जन.", "फेब्रु.", "मार्च", "अप्रि.", "मई", "जुन",
        "जुलाई.", "अग.", "सेप्ट.", "अक्टो.", "नोभे.", "डिसे.",
    },
    .day_names = .{
        "आइतबार", "सोमबार", "मङ्गलबार", "बुधबार",
        "बिहिबार", "शुक्रबार", "शनिबार",
    },
    .day_names_short = .{
        "आइत.", "सोम.", "मङ्गल.", "बुध.", "बिहि.", "शुक्र.", "शनि.",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

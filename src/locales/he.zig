const Locale = @import("../locale.zig").Locale;

/// Hebrew locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ינואר",   "פברואר",  "מרץ",     "אפריל",
        "מאי",     "יוני",    "יולי",    "אוגוסט",
        "ספטמבר",  "אוקטובר", "נובמבר",  "דצמבר",
    },
    .month_names_short = .{
        "ינו", "פבר", "מרץ", "אפר", "מאי", "יונ",
        "יול", "אוג", "ספט", "אוק", "נוב", "דצמ",
    },
    .day_names = .{
        "ראשון", "שני",   "שלישי", "רביעי",
        "חמישי", "שישי",  "שבת",
    },
    .day_names_short = .{
        "א׳", "ב׳", "ג׳", "ד׳", "ה׳", "ו׳", "ש׳",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

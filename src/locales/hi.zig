const Locale = @import("../locale.zig").Locale;

/// Hindi locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "जनवरी",  "फ़रवरी", "मार्च",   "अप्रैल",
        "मई",     "जून",    "जुलाई",  "अगस्त",
        "सितम्बर", "अक्टूबर", "नवम्बर", "दिसम्बर",
    },
    .month_names_short = .{
        "जन.",  "फ़र.",  "मार्च", "अप्रै.",
        "मई",   "जून",   "जुल.",  "अग.",
        "सित.", "अक्टू.", "नव.",   "दिस.",
    },
    .day_names = .{
        "रविवार",   "सोमवार",  "मंगलवार", "बुधवार",
        "गुरूवार",  "शुक्रवार", "शनिवार",
    },
    .day_names_short = .{
        "रवि", "सोम", "मंगल", "बुध", "गुरू", "शुक्र", "शनि",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

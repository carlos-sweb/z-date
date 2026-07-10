const Locale = @import("../locale.zig").Locale;

/// Marathi locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "जानेवारी",  "फेब्रुवारी", "मार्च",     "एप्रिल",
        "मे",        "जून",       "जुलै",      "ऑगस्ट",
        "सप्टेंबर",  "ऑक्टोबर",   "नोव्हेंबर", "डिसेंबर",
    },
    .month_names_short = .{
        "जाने.", "फेब्रु.", "मार्च.", "एप्रि.", "मे.", "जून.",
        "जुलै.", "ऑग.", "सप्टें.", "ऑक्टो.", "नोव्हें.", "डिसें.",
    },
    .day_names = .{
        "रविवार", "सोमवार", "मंगळवार", "बुधवार",
        "गुरूवार", "शुक्रवार", "शनिवार",
    },
    .day_names_short = .{
        "रवि", "सोम", "मंगळ", "बुध", "गुरू", "शुक्र", "शनि",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

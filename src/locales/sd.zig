const Locale = @import("../locale.zig").Locale;

/// Sindhi locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "جنوري",    "فيبروري", "مارچ",    "اپريل",
        "مئي",      "جون",     "جولاءِ",   "آگسٽ",
        "سيپٽمبر",  "آڪٽوبر", "نومبر",   "ڊسمبر",
    },
    .month_names_short = .{
        "جنوري",    "فيبروري", "مارچ",    "اپريل",
        "مئي",      "جون",     "جولاءِ",   "آگسٽ",
        "سيپٽمبر",  "آڪٽوبر", "نومبر",   "ڊسمبر",
    },
    .day_names = .{
        "آچر",   "سومر",  "اڱارو", "اربع",
        "خميس",  "جمع",   "ڇنڇر",
    },
    .day_names_short = .{
        "آچر", "سومر", "اڱارو", "اربع", "خميس", "جمع", "ڇنڇر",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

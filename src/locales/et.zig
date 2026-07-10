const Locale = @import("../locale.zig").Locale;

/// Estonian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "jaanuar",  "veebruar", "märts",    "aprill",
        "mai",      "juuni",    "juuli",    "august",
        "september", "oktoober", "november", "detsember",
    },
    .month_names_short = .{
        "jaan", "veebr", "märts", "apr", "mai", "juuni",
        "juuli", "aug", "sept", "okt", "nov", "dets",
    },
    .day_names = .{
        "pühapäev",  "esmaspäev", "teisipäev", "kolmapäev",
        "neljapäev", "reede",     "laupäev",
    },
    .day_names_short = .{
        "P", "E", "T", "K", "N", "R", "L",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

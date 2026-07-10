const Locale = @import("../locale.zig").Locale;

/// Basque locale: YYYY-MM-DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "urtarrila", "otsaila",  "martxoa", "apirila",
        "maiatza",   "ekaina",   "uztaila", "abuztua",
        "iraila",    "urria",    "azaroa",  "abendua",
    },
    .month_names_short = .{
        "urt.", "ots.", "mar.", "api.", "mai.", "eka.",
        "uzt.", "abu.", "ira.", "urr.", "aza.", "abe.",
    },
    .day_names = .{
        "igandea",    "astelehena", "asteartea", "asteazkena",
        "osteguna",   "ostirala",   "larunbata",
    },
    .day_names_short = .{
        "ig.", "al.", "ar.", "az.", "og.", "ol.", "lr.",
    },
    .date_order = .ymd,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

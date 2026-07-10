const Locale = @import("../locale.zig").Locale;

/// Central Atlas Tamazight (Latin script) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "innayr",  "brˤayrˤ", "marˤsˤ",    "ibrir",
        "mayyw",   "ywnyw",   "ywlywz",    "ɣwšt",
        "šwtanbir", "ktˤwbrˤ", "nwwanbir", "dwjnbir",
    },
    .month_names_short = .{
        "innayr",  "brˤayrˤ", "marˤsˤ",    "ibrir",
        "mayyw",   "ywnyw",   "ywlywz",    "ɣwšt",
        "šwtanbir", "ktˤwbrˤ", "nwwanbir", "dwjnbir",
    },
    .day_names = .{
        "asamas", "aynas",   "asinas", "akras",
        "akwas",  "asimwas", "asiḍyas",
    },
    .day_names_short = .{
        "asamas", "aynas", "asinas", "akras", "akwas", "asimwas", "asiḍyas",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

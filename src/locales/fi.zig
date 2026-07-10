const Locale = @import("../locale.zig").Locale;

/// Finnish locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "tammikuu",  "helmikuu",   "maaliskuu", "huhtikuu",
        "toukokuu",  "kesäkuu",    "heinäkuu",  "elokuu",
        "syyskuu",   "lokakuu",    "marraskuu", "joulukuu",
    },
    .month_names_short = .{
        "tammi", "helmi", "maalis", "huhti", "touko", "kesä",
        "heinä", "elo",   "syys",   "loka",  "marras", "joulu",
    },
    .day_names = .{
        "sunnuntai", "maanantai", "tiistai", "keskiviikko",
        "torstai",   "perjantai", "lauantai",
    },
    .day_names_short = .{
        "su", "ma", "ti", "ke", "to", "pe", "la",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
    .long_date_format = "D. MMMMta YYYY",
    .time_separator = '.',
};

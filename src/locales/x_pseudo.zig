const Locale = @import("../locale.zig").Locale;

/// Pseudo-localization test locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "J~áñúá~rý",  "F~ébrú~árý", "~Márc~h",   "Áp~ríl",
        "~Máý~",      "Júñé~",      "Júl~ý",     "Áú~gúst~",
        "Sép~témb~ér", "Ó~ctób~ér", "Ñ~óvém~bér", "~Décé~mbér",
    },
    .month_names_short = .{
        "J~áñ", "~Féb", "~Már", "~Ápr", "~Máý", "~Júñ",
        "~Júl", "~Áúg", "~Sép", "~Óct", "~Ñóv", "~Déc",
    },
    .day_names = .{
        "S~úñdá~ý", "Mó~ñdáý~", "Túé~sdáý~", "Wéd~ñésd~áý",
        "T~húrs~dáý", "~Fríd~áý", "S~átúr~dáý",
    },
    .day_names_short = .{
        "S~úñ", "~Móñ", "~Túé", "~Wéd", "~Thú", "~Frí", "~Sát",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

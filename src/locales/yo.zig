const Locale = @import("../locale.zig").Locale;

/// Yoruba locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Sẹ́rẹ́", "Èrèlè", "Ẹrẹ̀nà", "Ìgbé",
        "Èbibi",  "Òkùdu", "Agẹmo", "Ògún",
        "Owewe",  "Ọ̀wàrà", "Bélú",  "Ọ̀pẹ̀̀",
    },
    .month_names_short = .{
        "Sẹ́r", "Èrl", "Ẹrn", "Ìgb", "Èbi", "Òkù",
        "Agẹ",  "Ògú", "Owe", "Ọ̀wà", "Bél", "Ọ̀pẹ̀̀",
    },
    .day_names = .{
        "Àìkú",   "Ajé",  "Ìsẹ́gun", "Ọjọ́rú",
        "Ọjọ́bọ", "Ẹtì",  "Àbámẹ́ta",
    },
    .day_names_short = .{
        "Àìk", "Ajé", "Ìsẹ́", "Ọjr", "Ọjb", "Ẹtì", "Àbá",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

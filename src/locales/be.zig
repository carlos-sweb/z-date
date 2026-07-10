const Locale = @import("../locale.zig").Locale;

/// Belarusian locale: DD.MM.YYYY, 24-hour clock.
/// Note: dayjs's `be` locale uses grammatically-declined month names
/// (a function selecting genitive vs. nominative form depending on
/// context) instead of a fixed list; the genitive form (used in the
/// common "D MMMM YYYY" format) was chosen here as the static
/// month_names/month_names_short arrays. The meridiem function has
/// four time-of-day buckets (ночы/раніцы/дня/вечара); am_label/pm_label
/// approximate this with the closest before-/after-noon equivalents
/// (raniцы/дня) though time_24h is true so they are inert.
pub const locale: Locale = .{
    .month_names = .{
        "студзеня",   "лютага",     "сакавіка",   "красавіка",
        "траўня",     "чэрвеня",    "ліпеня",     "жніўня",
        "верасня",    "кастрычніка", "лістапада", "снежня",
    },
    .month_names_short = .{
        "студ", "лют", "сак", "крас", "трав", "чэрв",
        "ліп", "жнів", "вер", "каст", "ліст", "снеж",
    },
    .day_names = .{
        "нядзеля", "панядзелак", "аўторак", "серада",
        "чацвер",  "пятніца",    "субота",
    },
    .day_names_short = .{
        "няд", "пнд", "аўт", "сер", "чцв", "пят", "суб",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "раніцы",
    .pm_label = "дня",
};

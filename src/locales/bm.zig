const Locale = @import("../locale.zig").Locale;

/// Bambara locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Zanwuyekalo",   "Fewuruyekalo", "Marisikalo",    "Awirilikalo",
        "Mɛkalo",        "Zuwɛnkalo",    "Zuluyekalo",    "Utikalo",
        "Sɛtanburukalo", "ɔkutɔburukalo", "Nowanburukalo", "Desanburukalo",
    },
    .month_names_short = .{
        "Zan", "Few", "Mar", "Awi", "Mɛ", "Zuw",
        "Zul", "Uti", "Sɛt", "ɔku", "Now", "Des",
    },
    .day_names = .{
        "Kari", "Ntɛnɛn", "Tarata", "Araba",
        "Alamisa", "Juma", "Sibiri",
    },
    .day_names_short = .{
        "Kar", "Ntɛ", "Tar", "Ara", "Ala", "Jum", "Sib",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

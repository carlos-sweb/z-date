const Locale = @import("../locale.zig").Locale;

/// Kirundi locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Nzero",      "Ruhuhuma",   "Ntwarante",  "Ndamukiza",
        "Rusama",     "Ruhenshi",   "Mukakaro",   "Myandagaro",
        "Nyakanga",   "Gitugutu",   "Munyonyo",   "Kigarama",
    },
    .month_names_short = .{
        "Nzer", "Ruhuh", "Ntwar", "Ndam", "Rus", "Ruhen",
        "Muk", "Myand", "Nyak", "Git", "Muny", "Kig",
    },
    .day_names = .{
        "Ku wa Mungu",   "Ku wa Mbere",  "Ku wa Kabiri", "Ku wa Gatatu",
        "Ku wa Kane",    "Ku wa Gatanu", "Ku wa Gatandatu",
    },
    .day_names_short = .{
        "Kngu", "Kmbr", "Kbri", "Ktat", "Kkan", "Ktan", "Kdat",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

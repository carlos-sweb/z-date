const Locale = @import("../locale.zig").Locale;

/// Greek locale: D Month YYYY / DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Ιανουάριος",  "Φεβρουάριος", "Μάρτιος",    "Απρίλιος",
        "Μάιος",       "Ιούνιος",     "Ιούλιος",    "Αύγουστος",
        "Σεπτέμβριος", "Οκτώβριος",   "Νοέμβριος",  "Δεκέμβριος",
    },
    .month_names_short = .{
        "Ιαν", "Φεβ", "Μαρ", "Απρ", "Μαι", "Ιουν",
        "Ιουλ", "Αυγ", "Σεπτ", "Οκτ", "Νοε", "Δεκ",
    },
    .day_names = .{
        "Κυριακή", "Δευτέρα", "Τρίτη",     "Τετάρτη",
        "Πέμπτη",  "Παρασκευή", "Σάββατο",
    },
    .day_names_short = .{
        "Κυρ", "Δευ", "Τρι", "Τετ", "Πεμ", "Παρ", "Σαβ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};

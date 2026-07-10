const Locale = @import("../locale.zig").Locale;

/// Maori locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Kohi-tāte",       "Hui-tanguru",      "Poutū-te-rangi",       "Paenga-whāwhā",
        "Haratua",         "Pipiri",           "Hōngoingoi",           "Here-turi-kōkā",
        "Mahuru",          "Whiringa-ā-nuku", "Whiringa-ā-rangi",    "Hakihea",
    },
    .month_names_short = .{
        "Kohi",   "Hui",    "Pou",    "Pae",
        "Hara",   "Pipi",   "Hōngoi", "Here",
        "Mahu",   "Whi-nu", "Whi-ra", "Haki",
    },
    .day_names = .{
        "Rātapu", "Mane", "Tūrei", "Wenerei",
        "Tāite",  "Paraire", "Hātarei",
    },
    .day_names_short = .{
        "Ta", "Ma", "Tū", "We", "Tāi", "Pa", "Hā",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

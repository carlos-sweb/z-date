const Locale = @import("../locale.zig").Locale;

/// Lao locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ມັງກອນ", "ກຸມພາ",   "ມີນາ",   "ເມສາ",
        "ພຶດສະພາ", "ມິຖຸນາ",  "ກໍລະກົດ", "ສິງຫາ",
        "ກັນຍາ",   "ຕຸລາ",    "ພະຈິກ",  "ທັນວາ",
    },
    .month_names_short = .{
        "ມັງກອນ", "ກຸມພາ",   "ມີນາ",   "ເມສາ",
        "ພຶດສະພາ", "ມິຖຸນາ",  "ກໍລະກົດ", "ສິງຫາ",
        "ກັນຍາ",   "ຕຸລາ",    "ພະຈິກ",  "ທັນວາ",
    },
    .day_names = .{
        "ອາທິດ", "ຈັນ",  "ອັງຄານ", "ພຸດ",
        "ພະຫັດ", "ສຸກ", "ເສົາ",
    },
    .day_names_short = .{
        "ທິດ", "ຈັນ", "ອັງຄານ", "ພຸດ", "ພະຫັດ", "ສຸກ", "ເສົາ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};

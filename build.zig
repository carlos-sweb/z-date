const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the zdate module
    const zdate_module = b.addModule("zdate", .{
        .root_source_file = b.path("src/zdate.zig"),
    });

    // Tests
    const test_step = b.step("test", "Run library tests");

    const test_files = [_][]const u8{
        "tests/constants_test.zig",
        "tests/constructor_test.zig",
        "tests/getters_test.zig",
        "tests/setters_test.zig",
        "tests/parsing_test.zig",
        "tests/formatting_test.zig",
        "tests/edge_cases_test.zig",
        "tests/arithmetic_test.zig",
        "tests/iso8601_test.zig",
    };

    for (test_files, 0..) |test_file, i| {
        const test_name = std.fmt.allocPrint(
            b.allocator,
            "test_{d}",
            .{i},
        ) catch @panic("OOM");

        const unit_tests = b.addTest(.{
            .name = test_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(test_file),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "zdate", .module = zdate_module },
                },
            }),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }
}

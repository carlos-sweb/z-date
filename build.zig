const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the zdate module
    const zdate_module = b.addModule("zdate", .{
        .root_source_file = b.path("src/zdate.zig"),
    });

    // Documentation (zig-out/docs/index.html), generated from doc comments
    const docs_obj = b.addObject(.{
        .name = "zdate",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zdate.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const docs_step = b.step("docs", "Generate API documentation");
    docs_step.dependOn(&b.addInstallDirectory(.{
        .source_dir = docs_obj.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    }).step);

    // Immutable source snapshot used by differential tests and A/B benchmarks.
    const extract = b.addSystemCommand(&.{"python3"});
    extract.addFileArg(b.path("scripts/extract_baseline.py"));
    extract.addFileArg(b.path("benchmarks/baseline-zig-0.17.tar.gz"));
    extract.addFileArg(b.path("benchmarks/baseline.json"));
    const baseline_dir = extract.addOutputDirectoryArg2("baseline", .{});
    const baseline_module = b.createModule(.{
        .root_source_file = baseline_dir.path(b, "src/zdate.zig"),
        .target = target,
        .optimize = optimize,
    });
    const comparison = b.addTest(.{
        .name = "performance_equivalence",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/performance_equivalence_test.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zdate", .module = zdate_module },
                .{ .name = "baseline", .module = baseline_module },
            },
        }),
    });
    const bench = b.addExecutable(.{
        .name = "zdate-benchmark",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/compare.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zdate", .module = zdate_module },
                .{ .name = "baseline", .module = baseline_module },
            },
        }),
    });
    b.step("benchmark-build", "Build and install the comparison executable").dependOn(&b.addInstallArtifact(bench, .{}).step);
    const run_bench = b.addRunArtifact(bench);
    run_bench.has_side_effects = true;
    b.step("benchmark", "Compare optimized code against the preserved baseline").dependOn(&run_bench.step);

    // Tests
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(comparison).step);

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
        "tests/ecma_compliance_test.zig",
        "tests/locale_test.zig",
        "tests/overflow_safety_test.zig",
        "tests/dayjs_locales_test.zig",
        "tests/legacy_compat_test.zig",
        "tests/timezone_test.zig",
        "tests/v8_differential_test.zig",
        "tests/test262_port_test.zig",
    };

    for (test_files, 0..) |test_file, i| {
        const test_name = b.allocator.print(
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

const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const linkage = b.option(std.builtin.LinkMode, "linkage", "") orelse .static;

    const lightning = buildLightning(b, target, optimize, linkage);
    if (linkage == .dynamic) b.installArtifact(lightning);

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("libs/lightning/include/lightning.h"),
        .target = target,
        .optimize = optimize,
    });
    translate_c.addIncludePath(b.path("libs/lightning/include"));

    const c_module = translate_c.createModule();

    const module = b.addModule("root", .{
        .root_source_file = b.path("src/zjit.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "c", .module = c_module },
        },
    });
    module.linkLibrary(lightning);

    const example_files = &[_][]const u8{
        "examples/add.zig",
        "examples/callback.zig",
    };

    const examples_step = b.step("examples", "Build and run all examples");
    for (example_files) |path| {
        const name = std.fs.path.stem(path);
        const exe = b.addExecutable(.{
            .name = name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(path),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "zjit", .module = module },
                    .{ .name = "c", .module = c_module },
                },
            }),
        });
        b.installArtifact(exe);
        examples_step.dependOn(&b.addRunArtifact(exe).step);
    }

    const test_step = b.step("test", "Run zasm tests");
    const tests = b.addTest(.{
        .name = "zjit-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zjit.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "c", .module = c_module },
            },
        }),
    });
    tests.root_module.linkLibrary(lightning);
    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);
}

fn buildLightning(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    linkage: std.builtin.LinkMode,
) *std.Build.Step.Compile {
    const lib = b.addLibrary(.{
        .name = "lightning",
        .linkage = linkage,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    lib.root_module.link_libc = true;
    lib.installHeadersDirectory(b.path("libs/lightning/include"), "", .{});

    lib.root_module.addIncludePath(b.path("libs/lightning/include"));
    lib.root_module.addIncludePath(b.path("libs/lightning/lib"));
    lib.root_module.addIncludePath(b.path("libs/lightning"));

    const src = "libs/lightning/lib/";
    lib.root_module.addCSourceFiles(.{
        .files = &.{
            src ++ "lightning.c",
            src ++ "jit_memory.c",
            src ++ "jit_disasm.c",
            src ++ "jit_note.c",
            src ++ "jit_print.c",
            src ++ "jit_size.c",
        },
        .flags = &.{
            "-DHAVE_CONFIG_H",
            "-fno-sanitize=undefined",
        },
    });

    switch (target.result.os.tag) {
        .macos, .linux => lib.root_module.linkSystemLibrary("pthread", .{}),
        .windows => lib.root_module.addCMacro("WIN32", "1"),
        else => {},
    }

    return lib;
}

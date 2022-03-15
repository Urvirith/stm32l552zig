const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Add the target in new Zig format
    const target = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m33 },
        .os_tag = .freestanding,
        .abi = .eabi,
    };
    
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    // const mode = b.standardReleaseOptions(.ReleaseSmall);
    
    const start = b.addAssemble("startup", "./src/startup/startup_ARMCM33.s");
    start.setTarget(target);
    start.setBuildMode(.ReleaseSmall);
    start.strip = true;
    start.setOutputDir("./build");

    const main = b.addObject("main", "./src/main.zig");
    main.setTarget(target);
    main.setBuildMode(.ReleaseSmall);
    main.strip = true;
    main.setOutputDir("./build");

    b.default_step.dependOn(&start.step);
    b.default_step.dependOn(&main.step);

    const link_cmd = b.addSystemCommand(&[_][]const u8{
        "arm-none-eabi-ld",
        "-Os",
        "-s",
        "-T",
        "./src/linker/gcc_arm.ld",
        "build/startup.o",
        "build/main.o",
        "-o",
        "build/main.elf",
    });

    const obj_cmd = b.addSystemCommand(&[_][]const u8{
        "arm-none-eabi-objcopy",
        "-O",
        "binary",
        "build/main.elf",
        "build/main.bin",
    });

    b.default_step.dependOn(&link_cmd.step);
    b.default_step.dependOn(&obj_cmd.step);
}
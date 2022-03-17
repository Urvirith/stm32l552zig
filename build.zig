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
    const elf = b.addExecutable("main.elf", "src/main.zig");
    elf.setTarget(target);
    elf.setBuildMode(.ReleaseSmall);
    elf.strip = true;
    elf.setOutputDir("./build");

    const startup = b.addAssemble("startup", "src/startup/stm_ARMCM33.s");
    startup.setTarget(target);
    startup.setBuildMode(.ReleaseSmall);
    startup.strip = true;
    startup.setOutputDir("./build");

    elf.addObject(startup);
    elf.setLinkerScriptPath(.{ .path = "src/linker/stm_arm.ld" });
    elf.link_function_sections = true;

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);
}
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = std.zig.CrossTarget{
        .cpu_arch = .arm,
        .os_tag = .freestanding,
        .abi = .eabihf, // for hard float: gnueabihf
    };

    const optimize = b.standardOptimizeOption(.{});
    var exe_options = std.build.ExecutableOptions{
        .name = "Temp",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "Core/Src/main.c" },
    };
    const exe_step = b.addExecutable(exe_options);
    const exe = exe_step.step.cast(std.build.LibExeObjStep) orelse unreachable;

    // Add Include Directories
    const includeDirs = [_][]const u8{ "Core/Inc", "Drivers/STM32F4xx_HAL_Driver/Inc", "Drivers/STM32F4xx_HAL_Driver/Inc/Legacy", "Middlewares/Third_Party/FreeRTOS/Source/include", "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS", "Middlewares/Third_Party/FreeRTOS/Source/portable/gcc/ARM_CM4F", "Drivers/CMSIS/Device/ST/STM32F4xx/Include", "Drivers/CMSIS/Include" };

    for (includeDirs) |Headers| {
        const temp = std.Build.LazyPath{
            .path = Headers,
        };
        exe.addIncludePath(temp);
    }

    // Add source files.
    const srcFiles = &[_][]const u8{ "Core/Src/main.c", "Core/Src/gpio.c", "Core/Src/freertos.c", "Core/Src/i2c.c", "Core/Src/spi.c", "Core/Src/tim.c", "Core/Src/usart.c", "Core/Src/stm32f4xx_it.c", "Core/Src/stm32f4xx_hal_msp.c", "Core/Src/stm32f4xx_hal_timebase_tim.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c", "Core/Src/system_stm32f4xx.c", "Middlewares/Third_Party/FreeRTOS/Source/croutine.c", "Middlewares/Third_Party/FreeRTOS/Source/event_groups.c", "Middlewares/Third_Party/FreeRTOS/Source/list.c", "Middlewares/Third_Party/FreeRTOS/Source/queue.c", "Middlewares/Third_Party/FreeRTOS/Source/stream_buffer.c", "Middlewares/Third_Party/FreeRTOS/Source/tasks.c", "Middlewares/Third_Party/FreeRTOS/Source/timers.c", "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS/cmsis_os.c", "Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c", "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c" };

    exe.addCSourceFiles(srcFiles, &.{ "-Og", "-Wall" });

    // Add ASM Sources
    const asm_sources = &[_][]const u8{
        "startup_stm32f401xe.s",
    };

    exe.addCSourceFiles(asm_sources, &.{
        "-x",               "assembler-with-cpp",
        "-mcpu=cortex-m4",  "-mfpu=fpv4-sp-d16",
        "-mfloat-abi=hard", "-mthumb",
    });

    // C Flags
    // @!TODO: FIX
    exe.addCDefine("USE_HAL_DRIVER", "");
    exe.addCDefine("STM32F401xE", "");
    exe.addCFlags(&.{
        "-mthumb",
        "-mcpu=cortex-m4",
        "-mfpu=fpv4-sp-d16",
        "-mfloat-abi=hard",
        "-Wall",
        "-fdata-sections",
        "-ffunction-sections",
        "-Og",
    });

    // Add debug flags if building in debug mode.
    if (optimize == .Debug) {
        exe.addCFlags(&.{ "-g", "-gdwarf-2" });
    }

    // Setup linker script and flags.
    exe.setLinkerScriptPath("STM32F401RETx_FLASH.ld");
    exe.addLinkerFlags(&.{
        "-specs=nano.specs",
        "-Wl,-Map=${b.cache_root}/Temp.map",
        "-Wl,--cref",
        "-Wl,--gc-sections",
    });

    // Add system libraries as needed.
    exe.addLibC();
    exe.addLibM();
    exe.linkSystemLibrary("nosys");

    // Setup the output directory.
    const out_dir = "build";
    exe.setOutputDir(out_dir); // Doesnt work

    const elf_path = exe.getOutputPath(); // Doesnt work
    const hex_step = b.addSystemCommand(&.{
        "arm-none-eabi-objcopy", "-O", "ihex", elf_path, "${out_dir}/Temp.hex",
    });
    const bin_step = b.addSystemCommand(&.{
        "arm-none-eabi-objcopy", "-O", "binary", elf_path, "${out_dir}/Temp.bin",
    });

    b.default_step.dependOn(&hex_step.step);
    b.default_step.dependOn(&bin_step.step);

    const clean = b.addStep("clean", "Clean up build artifacts", .{});
    clean.dependOn(&b.fs.deletePath(out_dir, .{}));
}

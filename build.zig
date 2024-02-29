const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Setting up target and optimization
    const target = std.zig.CrossTarget{
        .cpu_arch = .arm,
        .os_tag = .freestanding,
        .abi = .eabihf, // for hard float: gnueabihf
    };
    const optimize = b.standardOptimizeOption(.{});

    // Setup Library
    const lib = b.addStaticLibrary(.{
        .name = "SDL2",
        .target = target,
        .optimize = optimize,
    });

    // Include Headers
    for (includeDirs) |Headers| {
        const temp = std.Build.LazyPath{
            .path = Headers,
        };
        lib.addIncludePath(temp);
    }

    lib.addcSo

    // Add C Source Files
    lib.addCSourceFiles(srcFiles, &.{
        "-Og",
        "-Wall",
        "-mthumb",
        "-mcpu=cortex-m4",
        "-mfpu=fpv4-sp-d16",
        "-mfloat-abi=hard",
        "-fdata-sections",
        "-ffunction-sections",
    });

    // Add ASM source files
    lib.addCSourceFiles(asm_sources, &.{
        "-x",               "assembler-with-cpp",
        "-mcpu=cortex-m4",  "-mfpu=fpv4-sp-d16",
        "-mfloat-abi=hard", "-mthumb",
    });

    // Define Setup
    lib.defineCMacro("USE_HAL_DRIVER", "");
    lib.defineCMacro("STM32F401xE", "");

    // Linking Stage
    lib.linkLibC();
    //lib.linkSystemLibrary("nosys");
    //lib.linkSystemLibrary("nano");
    //lib.addLinkerFlags(&.{
    //    "-specs=nano.specs",
    //    "-Wl,-Map=${b.cache_root}/Temp.map",
    //    "-Wl,--cref",
    //    "-Wl,--gc-sections",
    //});

    // Uploading Stage (CLIENT SIDE)
    // Linker Script

    lib.installHeadersDirectory("Drivers/STM32F4xx_HAL_Driver/Inc", "Drivers");
    lib.installHeadersDirectory("Drivers/STM32F4xx_HAL_Driver/Inc/Legacy", "DriversLegacy");
    lib.installHeadersDirectory("Middlewares/Third_Party/FreeRTOS/Source/include", "FreeRTOS");
    lib.installHeadersDirectory("Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS", "CMSIS_RTOS");
    lib.installHeadersDirectory("Middlewares/Third_Party/FreeRTOS/Source/portable/gcc/ARM_CM4F", "FreeRTOSARM");
    lib.installHeadersDirectory("Drivers/CMSIS/Device/ST/STM32F4xx/Include", "STM32F4xx");
    lib.installHeadersDirectory("Drivers/CMSIS/Include", "CMSIS");
    b.installArtifact(lib);
}

const srcFiles = &[_][]const u8{ "Core/Src/main.c", "Core/Src/gpio.c", "Core/Src/freertos.c", "Core/Src/i2c.c", "Core/Src/spi.c", "Core/Src/tim.c", "Core/Src/usart.c", "Core/Src/stm32f4xx_it.c", "Core/Src/stm32f4xx_hal_msp.c", "Core/Src/stm32f4xx_hal_timebase_tim.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c", "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c", "Core/Src/system_stm32f4xx.c", "Middlewares/Third_Party/FreeRTOS/Source/croutine.c", "Middlewares/Third_Party/FreeRTOS/Source/event_groups.c", "Middlewares/Third_Party/FreeRTOS/Source/list.c", "Middlewares/Third_Party/FreeRTOS/Source/queue.c", "Middlewares/Third_Party/FreeRTOS/Source/stream_buffer.c", "Middlewares/Third_Party/FreeRTOS/Source/tasks.c", "Middlewares/Third_Party/FreeRTOS/Source/timers.c", "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS/cmsis_os.c", "Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c", "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c" };

const includeDirs = [_][]const u8{ "Drivers/STM32F4xx_HAL_Driver/Inc", "Drivers/STM32F4xx_HAL_Driver/Inc/Legacy", "Middlewares/Third_Party/FreeRTOS/Source/include", "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS", "Middlewares/Third_Party/FreeRTOS/Source/portable/gcc/ARM_CM4F", "Drivers/CMSIS/Device/ST/STM32F4xx/Include", "Drivers/CMSIS/Include" };

const asm_sources = &[_][]const u8{
    "startup_stm32f401xe.s",
};

const MCflags = &[_][]const u8{ 
    "-mcpu=cortex-m4",
    "-mfpu=fpv4-sp-d16",
    "-mfloat-abi=hard",
    "-mthumb",
};

const Op = &[_][]const u8{ 
    "-Og",
};

const Debug = &[_][]const u8{ 
    "-g",
    "-gdwarf-2",
};

const Cflags = &[_][]const u8{ 
    // MCU
    MCflags,
    // C Defs
    "-DUSE_HAL_DRIVER",
    "-DSTM32F401xE",
    // C Includes
    includeDirs,
    // Optimizaiton
    Op,
    // Debug
    //Debug,
};

const ASflags = &[_][]const u8{ 
    // MCU
    MCflags,
    // AS Defs
    // AS Includes
    "-ICore/Inc",
    // Optimization
    Op,
    // Debug
    //Debug,
};







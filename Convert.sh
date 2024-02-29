#!/bin/bash

C_BASE_DIR="./"
ZIG_BASE_DIR="./ZigFiles"

mkdir -p "$ZIG_BASE_DIR"

C_SOURCES=(
  "Core/Src/main.c"
  "Core/Src/gpio.c"
  "Core/Src/i2c.c"
  "Core/Src/spi.c"
  "Core/Src/tim.c"
  "Core/Src/usart.c"
  "Core/Src/stm32f4xx_it.c"
  "Core/Src/stm32f4xx_hal_msp.c"
  "Core/Src/stm32f4xx_hal_timebase_tim.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c_ex.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c"
  "Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c"
  "Core/Src/system_stm32f4xx.c"
)


for c_file in "${C_SOURCES[@]}"; do
  zig_file=$(basename "${c_file%.c}.zig")

  zig translate-c "${C_BASE_DIR}/${c_file}" \
    -I Core/Inc \
    -I Drivers/STM32F4xx_HAL_Driver/Inc \
    -I Drivers/STM32F4xx_HAL_Driver/Inc/Legacy \
    -I Drivers/CMSIS/Device/ST/STM32F4xx/Include \
    -I Drivers/CMSIS/Include \
    -I newlib-cygwin/newlib/libc/include \
    -I newlib-cygwin/include \
    -D USE_HAL_DRIVER \
    -D STM32F401xE \
    --name "$(basename "${zig_file%.zig}")" > "${ZIG_BASE_DIR}/${zig_file}"
done


echo "Conversion complete."



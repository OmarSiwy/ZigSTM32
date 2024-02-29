# STM32 HAL Library in Zig 🚀

This repository explores the exciting journey of adapting the STM32 HAL (Hardware Abstraction Layer) library for use with the Zig programming language. Zig, known for its emphasis on performance and minimal binary size, presents a compelling case for systems programming. Our motivation for this endeavor stems from Zig's potential to enhance the efficiency and footprint of embedded applications traditionally developed in C.

## 🌟 Motivation

Zig offers several advantages that make it an attractive choice for systems programming, particularly in the embedded domain:

- **Performance:** Zig's focus on generating efficient machine code can lead to faster runtime performance.
- **Binary Size:** Zig's ability to produce minimal binary sizes is crucial for resource-constrained environments like microcontrollers.

For benchmarks and comparisons that highlight Zig's capabilities in these areas, check out the following resources:
- [Zig Binary Size Benchmark](https://github.com/MichalStrehovsky/sizegame)
- [Zig Performance Benchmark](https://github.com/ziglang/gotta-go-fast)

## 🛠 Steps Towards STM32 HAL in Zig

In our quest to bring the STM32 HAL library into the Zig ecosystem, we've undertaken several approaches:

- [x] **1. Compile C files using Zig CC:** Our initial step involved using Zig's `zig cc` command to compile the C source files into Zig code and subsequently into binaries. This process also included leveraging a Makefile to link against existing C libraries.

- [x] **2. Attempt Zig Translate-C:** We experimented with Zig's `translate-c` feature to convert the C codebase of the HAL library directly into Zig. However, this approach faced challenges due to the library's heavy reliance on `#define` macros, which don't translate well in large libraries when using Zig's automated tools.

- [x] **3. Static Library Consideration:** We considered packaging the HAL library as a static library for use within Zig projects. However, this idea was ultimately abandoned as it did not offer the anticipated benefits in performance or binary size reduction.

## 📈 Future Directions

While our initial attempts have faced challenges, our journey is far from over. We are continuously exploring new strategies and optimizations to fully harness Zig's potential in the context of the STM32 HAL library. Key to our future efforts will be the rewriting of the STM32 HAL library, generalizing it for ARM processors at large. This ambitious undertaking will be informed and supported by the resources and community around [libopencm3](https://github.com/libopencm3/libopencm3/tree/master), an open-source library that provides low-level APIs for ARM Cortex microcontrollers. By leveraging libopencm3's extensive work, we aim to create a more versatile and efficient library that benefits a wider range of ARM-based projects. Stay tuned for updates and breakthroughs!

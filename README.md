# WASM Error Diffusion Dither Comparison

A comparison of error diffusion dither performance using the [Stucki error diffusion dither algorithm](https://tannerhelland.com/2012/12/28/dithering-eleven-algorithms-source-code.html#stucki-dithering) between JavaScript and WebAssembly generated from C++, D, Rust and Zig.

## JavaScript Dependencies

* node >= 16.14
* npm

## WebAssembly Dependencies

* make
* POSIX compatible operating system

### C++

* [emcc](https://emscripten.org) >= 3.1.10

### D

* [ldc2](https://github.com/ldc-developers/ldc) >= 1.29.0

### Rust

* [rustup](https://rustup.rs/) >= 1.24.3
* [wasm-pack](https://github.com/rustwasm/wasm-pack) 0.10.2

### Zig

* [zig](https://ziglang.org/download/) 0.9.1

## Getting Started

* `npm install`
* `npm start`

## Compiling WebAssembly (only required if changing WebAssembly source files)

* Make sure you have all WebAssembly dependencies installed
* `make`

## Docker

Alternatively you can run using Docker (x86-64 architecture only)

* `docker build -t wasm-dither .`
* `docker run -p 3000:3000 wasm-dither`

## License

WASM Error Diffusion Dither Comparison is released under the MIT License. See license.txt for more details.
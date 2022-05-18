# WASM Error Propagation Dither Comparison

A comparison of error propagation dither performance between JavaScript and WebAssembly generated from C++, D, Rust and Zig.

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

## License

WASM Error Propagation Dither Comparison is released under the MIT License. See license.txt for more details.
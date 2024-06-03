
WASM_OUTPUT_DIR=public/assets

CPP_SRC_DIR=wasm/cpp
CPP_SRC=$(CPP_SRC_DIR)/main.cpp
CPP_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/cpp.wasm

D_SRC_DIR=wasm/d
D_SRC=$(D_SRC_DIR)/main.d
D_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/d.wasm

RUST_SRC_DIR=wasm/rust
RUST_SRC=$(RUST_SRC_DIR)/src/lib.rs
RUST_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/rust.wasm

ZIG_SRC_DIR=wasm/zig
ZIG_SRC=$(ZIG_SRC_DIR)/main.zig
ZIG_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/zig.wasm

all: $(D_WASM_OUTPUT) $(ZIG_WASM_OUTPUT) $(CPP_WASM_OUTPUT) $(RUST_WASM_OUTPUT)

$(CPP_WASM_OUTPUT): $(CPP_SRC)
	emcc -O2 $(CPP_SRC) -o $(CPP_WASM_OUTPUT) --no-entry -sEXPORTED_FUNCTIONS=_dither -sALLOW_MEMORY_GROWTH=1

$(D_WASM_OUTPUT): $(D_SRC)
	ldc2 -mtriple=wasm32-unknown-unknown-wasm -betterC --release -O $(D_SRC) -of=$(D_WASM_OUTPUT) -od=$(D_SRC_DIR)

$(ZIG_WASM_OUTPUT): $(ZIG_SRC)
	zig build-lib $(ZIG_SRC) -dynamic -O ReleaseSmall -rdynamic -target wasm32-freestanding
	mv ./main.wasm $(ZIG_WASM_OUTPUT)

$(RUST_WASM_OUTPUT): $(RUST_SRC)
	cd $(RUST_SRC_DIR) ; wasm-pack build --target web
	mv $(RUST_SRC_DIR)/pkg/dither_bg.wasm $(RUST_WASM_OUTPUT)

clean:
	rm $(WASM_OUTPUT_DIR)/*.wasm
	rm -rf wasm/zig/zig-cache

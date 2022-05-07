
WASM_OUTPUT_DIR=public/assets

D_SRC_DIR=wasm/d
D_SRC=$(D_SRC_DIR)/main.d
D_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/d.wasm

ZIG_SRC_DIR=wasm/zig
ZIG_SRC=$(ZIG_SRC_DIR)/main.zig
ZIG_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/zig.wasm

all: $(D_WASM_OUTPUT) $(ZIG_WASM_OUTPUT)

$(D_WASM_OUTPUT): $(D_SRC)
	ldc2 -mtriple=wasm32-unknown-unknown-wasm -betterC -O $(D_SRC) -of=$(D_WASM_OUTPUT) -od=$(D_SRC_DIR)

$(ZIG_WASM_OUTPUT): $(ZIG_SRC)
	zig build-lib $(ZIG_SRC) -dynamic -O ReleaseSmall -target wasm32-freestanding
	mv ./main.wasm $(ZIG_WASM_OUTPUT)

clean:
	rm $(WASM_OUTPUT_DIR)/*.wasm
	rm -rf wasm/zig/zig-cache

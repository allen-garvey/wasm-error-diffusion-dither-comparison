
WASM_OUTPUT_DIR=public/assets

D_SRC_DIR=wasm/d
D_SRC=$(D_SRC_DIR)/main.d
D_WASM_OUTPUT=$(WASM_OUTPUT_DIR)/d.wasm

all: $(D_WASM_OUTPUT)

$(D_WASM_OUTPUT): $(D_SRC)
	ldc2 -mtriple=wasm32-unknown-unknown-wasm -betterC -O $(D_SRC) -of=$(D_WASM_OUTPUT) -od=$(D_SRC_DIR)

clean:
	rm $(WASM_OUTPUT_DIR)/*.wasm

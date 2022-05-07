export const ditherWasm = (wasmExports, pixels, imageWidth, imageHeight) => {
    const ditheredPixels = new Uint8ClampedArray(wasmExports.memory.buffer, 0, pixels.length);
    ditheredPixels.set(pixels);
    const errorArray = new Float32Array(wasmExports.memory.buffer, pixels.length, (imageWidth + 4) * 3);
    errorArray.fill(0);

    const startTime = performance.now();
    wasmExports.dither(0, imageWidth, imageHeight, pixels.buffer.byteLength);
    const timeElapsed = (performance.now() - startTime) / 1000;

    return {
        pixels: ditheredPixels.slice(),
        timeElapsed,
    };
};

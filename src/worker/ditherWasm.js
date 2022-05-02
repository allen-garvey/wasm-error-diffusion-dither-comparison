export const ditherWasm = (ditherFunc, pixels, imageWidth, imageHeight) => {
    const ditheredPixels = pixels.slice();
    const errorArray = new Int16Array((imageWidth + 4) * 3);

    const startTime = performance.now();
    ditherFunc(ditheredPixels.buffer, imageWidth, imageHeight, errorArray.buffer);
    const timeElapsed = (performance.now() - startTime) / 1000;

    return {
        pixels: ditheredPixels,
        timeElapsed,
    };
};

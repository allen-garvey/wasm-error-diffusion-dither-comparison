const calculateLightness = (r, g, b) => {
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    return Math.floor((max + min) / 2);
};


// dither with stucki dithering algorithm 
// https://tannerhelland.com/2012/12/28/dithering-eleven-algorithms-source-code.html#stucki-dithering
export const dither = (pixels, imageWidth, imageHeight) => {
    const ditheredPixels = new Uint8ClampedArray(pixels.length).fill(255);
    // add 2 to beginning and end so we don't need to do bounds checks
    const errorDiffusionWidth = imageWidth + 4;
    let row1 = new Int16Array(errorDiffusionWidth);
    let row2 = new Int16Array(errorDiffusionWidth);
    let row3 = new Int16Array(errorDiffusionWidth);

    const startTime = performance.now();
    for(let y=0,pixelIndex=0; y<imageHeight; y++){
        for(let x=0,errorIndex=2;x<imageWidth;x++,pixelIndex+=4,errorIndex++){
            const storedError = row1[errorIndex];
            const lightness = calculateLightness(pixels[pixelIndex], pixels[pixelIndex+1], pixels[pixelIndex+2]);
            const adjustedLightness = storedError + lightness;
            const outputValue = adjustedLightness > 127 ? 255 : 0;

            ditheredPixels[pixelIndex] = outputValue;
            ditheredPixels[pixelIndex+1] = outputValue;
            ditheredPixels[pixelIndex+2] = outputValue;

            const errorFraction = Math.round((adjustedLightness - outputValue) / 42);
            const errorFraction2 = errorFraction * 2;
            const errorFraction4 = errorFraction * 4;
            const errorFraction8 = errorFraction * 8;

            row1[errorIndex+1] = errorFraction8;
            row1[errorIndex+2] = errorFraction4;

            row2[errorIndex-2] = errorFraction2;
            row2[errorIndex-1] = errorFraction4;
            row2[errorIndex] = errorFraction8;
            row2[errorIndex+1] = errorFraction4;
            row2[errorIndex+2] = errorFraction2;

            row3[errorIndex-2] = errorFraction;
            row3[errorIndex-1] = errorFraction2;
            row3[errorIndex] = errorFraction4;
            row3[errorIndex+1] = errorFraction2;
            row3[errorIndex+2] = errorFraction;
        }
        row1.fill(0);
        const temp = row1;
        row1 = row2;
        row2 = row3;
        row3 = temp;
    }
    const timeElapsed = (performance.now() - startTime) / 1000;
    return {
        pixels: ditheredPixels,
        timeElapsed,
    };
};

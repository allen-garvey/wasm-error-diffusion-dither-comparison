const calculateLightness = (r: u8, g: u8, b: u8): f32 => {
    // have to mix Math and Mathf since otherwise will get
    // function can't be inlined to itself error
    const max = Mathf.max(Math.max(r, g) as f32, b);
    const min = Mathf.min(Math.min(r, g) as f32, b);
    return (max as f32 + min as f32) / 2;
};

export function dither(pixelBuffer: usize, imageWidth: u32, imageHeight: u32, errorBuffer: usize): void {
    // const pixelsLength = imageWidth * imageHeight * 4;
    // const pixels: u8[] = load<u8>(pixelsLength, pixelBuffer);
    // add 2 to beginning and end so we don't need to do bounds checks
    // const errorDiffusionWidth = imageWidth + 4;
    // let errorRow1 = new Float32Array(errorBuffer, 0, errorDiffusionWidth);
    // let errorRow2 = new Float32Array(errorBuffer, errorDiffusionWidth * 4, errorDiffusionWidth);
    // let errorRow3 = new Float32Array(errorBuffer, errorDiffusionWidth * 8, errorDiffusionWidth);

    for(let y:u32=0,pixelIndex=0; y<imageHeight; y++){
        for(let x:u32=0,errorIndex=2;x<imageWidth;x++,pixelIndex+=4,errorIndex++){
            // const storedError = errorRow1[errorIndex];
            const storedError: f32 = 0.0;
            const lightness = calculateLightness(load<u8>(pixelBuffer+pixelIndex), load<u8>(pixelBuffer+pixelIndex+1), load<u8>(pixelBuffer+pixelIndex+2));
            const adjustedLightness = storedError + lightness;
            const outputValue: u8 = adjustedLightness > 127 ? 255 : 0;

            store<u8>(pixelBuffer+pixelIndex, outputValue);
            store<u8>(pixelBuffer+pixelIndex+1, outputValue);
            store<u8>(pixelBuffer+pixelIndex+2, outputValue);

            // let errorFraction = (adjustedLightness - outputValue) / 42;
            // const errorFraction2 =  errorFraction * 2;
            // const errorFraction4 =  errorFraction * 4;
            // const errorFraction8 =  errorFraction * 8;

            // errorRow1[errorIndex+1] += errorFraction8;
            // errorRow1[errorIndex+2] += errorFraction4;

            // errorRow2[errorIndex-2] += errorFraction2;
            // errorRow2[errorIndex-1] += errorFraction4;
            // errorRow2[errorIndex] += errorFraction8;
            // errorRow2[errorIndex+1] += errorFraction4;
            // errorRow2[errorIndex+2] += errorFraction2;

            // errorRow3[errorIndex-2] += errorFraction;
            // errorRow3[errorIndex-1] += errorFraction2;
            // errorRow3[errorIndex] += errorFraction4;
            // errorRow3[errorIndex+1] += errorFraction2;
            // errorRow3[errorIndex+2] += errorFraction;
        }
        // errorRow1.fill(0);
        // const temp = errorRow1;
        // errorRow1 = errorRow2;
        // errorRow2 = errorRow3;
        // errorRow3 = temp;
    }
};
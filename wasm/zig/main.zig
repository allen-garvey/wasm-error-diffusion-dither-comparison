const math = @import("std").math;

fn calculateLightness(r: u8, g: u8, b: u8) u8{
    const maxValue: u8 = math.max3(r, g, b);
    const minValue: u8 = math.min3(r, g, b);
    return (maxValue + minValue) / 2;
}
 
 export fn dither(pixelsBuffer: [*]u8, imageWidth: u32, imageHeight: u32, errorsBuffer: [*]i16) void {
    //* 4 since RGBA format
    const pixelsLength: usize = imageWidth * imageHeight * 4;
    const pixels: []u8 = pixelsBuffer[0 .. pixelsLength];

    // buffer on either side of error array to avoid bounds checking
    const errorArrayLength: usize = imageWidth + 4;
    var errorRow1: []i16 = errorsBuffer[0 .. errorArrayLength];
    var errorRow2: []i16 = errorsBuffer[errorArrayLength .. 2 * errorArrayLength];
    var errorRow3: []i16 = errorsBuffer[2 * errorArrayLength .. 3 * errorArrayLength];

    var pixelIndex: usize = 0;

    var y: i32 = 0;
    while (y < imageHeight) : (y += 1) {
        var errorIndex: usize = 2;
        var x: i32 = 0;
        
        while (x < imageWidth) : (x += 1) {
            const storedError: i16 = errorRow1[errorIndex];
            const lightness: u8 = calculateLightness(pixels[pixelIndex], pixels[pixelIndex+1], pixels[pixelIndex+2]);
            const adjustedLightness: i16 = storedError + lightness;
            const outputValue: u8 = if (adjustedLightness > 127) 
                255
            else
                0;
            
            //set color in pixels
            pixels[pixelIndex] = outputValue;
            pixels[pixelIndex+1] = outputValue;
            pixels[pixelIndex+2] = outputValue;

            // save error
            const errorFraction: i16 = @floatToInt(i16, math.round(@intToFloat(f32, adjustedLightness - outputValue) / 42.0));
            const errorFraction2: i16 = errorFraction * 2;
            const errorFraction4: i16 = errorFraction * 4;
            const errorFraction8: i16 = errorFraction * 8;

            errorRow1[errorIndex+1] += errorFraction8;
            errorRow1[errorIndex+2] += errorFraction4;

            errorRow2[errorIndex-2] += errorFraction2;
            errorRow2[errorIndex-1] += errorFraction4;
            errorRow2[errorIndex] += errorFraction8;
            errorRow2[errorIndex+1] += errorFraction4;
            errorRow2[errorIndex+2] += errorFraction2;

            errorRow3[errorIndex-2] += errorFraction;
            errorRow3[errorIndex-1] += errorFraction2;
            errorRow3[errorIndex] += errorFraction4;
            errorRow3[errorIndex+1] += errorFraction2;
            errorRow3[errorIndex+2] += errorFraction;

            pixelIndex += 4;
            errorIndex += 1;
        }

        for (errorRow1) |_, i| {
            errorRow1[i] = 0;
        }
        
        const temp: []i16 = errorRow1;
        errorRow1 = errorRow2;
        errorRow2 = errorRow3;
        errorRow3 = temp;
    }
}
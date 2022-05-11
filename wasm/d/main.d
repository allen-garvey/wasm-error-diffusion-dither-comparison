extern(C): // disable D mangling

ubyte max(ubyte v1, ubyte v2, ubyte v3)
{
    if (v1 > v2)
        return v1 > v3 ? v1 : v3;
    return v2 > v3 ? v2 : v3;
}

ubyte min(ubyte v1, ubyte v2, ubyte v3)
{
    if (v1 < v2)
        return v1 < v3 ? v1 : v3;
    return v2 < v3 ? v2 : v3;
}

float calculateLightness(ubyte r, ubyte g, ubyte b)
{
    const maxValue = max(r, g, b);
    const minValue = min(r, g, b);
    return (maxValue + minValue) / 2.0;
}

void dither(ubyte* pixelsBuffer, int imageWidth, int imageHeight, float* errorsBuffer)
{
    //* 4 since RGBA format
    const pixelsLength = (cast(size_t) imageWidth) * imageHeight * 4;
    ubyte[] pixels = pixelsBuffer[0 .. pixelsLength];

    // buffer on either side of error array to avoid bounds checking
    const errorArrayLength = imageWidth + 4;
    float[] errorRow1 = errorsBuffer[0 .. errorArrayLength];
    float[] errorRow2 = errorsBuffer[errorArrayLength .. 2 * errorArrayLength];
    float[] errorRow3 = errorsBuffer[2 * errorArrayLength .. 3 * errorArrayLength];

    size_t pixelIndex = 0;
    foreach (y; 0 .. imageHeight)
    {
        int errorIndex = 2;
        
        foreach (x; 0 .. imageWidth)
        {
            const storedError = errorRow1[errorIndex];
            const lightness = calculateLightness(pixels[pixelIndex], pixels[pixelIndex+1], pixels[pixelIndex+2]);
            const adjustedLightness = storedError + lightness;
            ubyte outputValue = adjustedLightness > 127 ? 255 : 0;

            //set color in pixels
            pixels[pixelIndex .. pixelIndex+3] = outputValue;

            // save error
            const errorFraction = (adjustedLightness - outputValue) / 42.0;
            const errorFraction2 = errorFraction * 2;
            const errorFraction4 = errorFraction * 4;
            const errorFraction8 = errorFraction * 8;

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
            errorIndex++;
        }

        errorRow1[0 .. errorRow1.length] = 0.0;
        
        float[] temp = errorRow1;
        errorRow1 = errorRow2;
        errorRow2 = errorRow3;
        errorRow3 = temp;
    }
}
/*
* Conditionally include assert stub so compiles for webassembly but will still work on other platforms
* Also need memset, since even if change to use for loop compiler will still call memset
*/
version(WebAssembly){
    void __assert(const(char)* msg, const(char)* file, uint line) {}

    // value needs to be int, since for some reason bug in compiler
    // causes 0 to be sent in as i32 value instead of f32
    float* memset(float* a, int value, size_t n)
    {   
        for(size_t i=0;i<n;i++)
        {
            a[i] = value;
        }

        return a;
    }
}

// seems to be the required entry point
void _start() {}
//main entry point
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

ubyte calculateLightness(ubyte r, ubyte g, ubyte b)
{
    const maxValue = max(r, g, b);
    const minValue = min(r, g, b);
    return (maxValue + minValue) / 2;
}

void zerroArray(short[] array)
{
    foreach (i, value; array) 
    {
        array[i] = 0;
    }
}

short round(float f)
{
    short lower = cast(short) f;
    const error = f - lower;

    return error >= 0.5 ? cast(short) (lower + 1) : lower;
}

void dither(ubyte* pixelsBuffer, int imageWidth, int imageHeight, short* errorsBuffer)
{
    //* 4 since RGBA format
    const pixelsLength = (cast(size_t) imageWidth) * imageHeight * 4;
    ubyte[] pixels = pixelsBuffer[0 .. pixelsLength];

    // buffer on either side of error array to avoid bounds checking
    const errorArrayLength = imageWidth + 4;
    short[] errorRow1 = errorsBuffer[0 .. errorArrayLength];
    short[] errorRow2 = errorsBuffer[errorArrayLength .. 2 * errorArrayLength];
    short[] errorRow3 = errorsBuffer[2 * errorArrayLength .. 3 * errorArrayLength];

    size_t pixelIndex = 0;
    foreach (y; 0 .. imageHeight)
    {

        int errorIndex = 2;
        
        foreach (x; 0 .. imageWidth)
        {
            short storedError = errorRow1[errorIndex];
            const lightness = calculateLightness(pixels[pixelIndex], pixels[pixelIndex+1], pixels[pixelIndex+2]);
            short adjustedLightness = cast(short) (storedError + lightness);
            ubyte outputValue = adjustedLightness > 127 ? 255 : 0;

            //set color in pixels
            pixels[pixelIndex .. pixelIndex+3] = outputValue;

            // save error
            short errorFraction = round((adjustedLightness - outputValue) / 42.0);
            short errorFraction2 = cast(short) (errorFraction * 2);
            short errorFraction4 = cast(short) (errorFraction * 4);
            short errorFraction8 = cast(short) (errorFraction * 8);

            errorRow1[errorIndex+1] = errorFraction8;
            errorRow1[errorIndex+2] = errorFraction4;

            errorRow2[errorIndex-2] = errorFraction2;
            errorRow2[errorIndex-1] = errorFraction4;
            errorRow2[errorIndex] = errorFraction8;
            errorRow2[errorIndex+1] = errorFraction4;
            errorRow2[errorIndex+2] = errorFraction2;

            errorRow3[errorIndex-2] = errorFraction;
            errorRow3[errorIndex-1] = errorFraction2;
            errorRow3[errorIndex] = errorFraction4;
            errorRow3[errorIndex+1] = errorFraction2;
            errorRow3[errorIndex+2] = errorFraction;

            pixelIndex += 4;
            errorIndex++;
        }

        zerroArray(errorRow1);
        short[] temp = errorRow1;
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

    void memset(short[] a, short value, size_t n)
    {
        for(size_t i=0;i<n;i++)
        {
            a[i] = value;
        }
    }
}

// seems to be the required entry point
void _start() {}
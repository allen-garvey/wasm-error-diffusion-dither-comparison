#define size_t unsigned long

unsigned char max(unsigned char v1, unsigned char v2, unsigned char v3)
{
    if (v1 > v2)
        return v1 > v3 ? v1 : v3;
    return v2 > v3 ? v2 : v3;
}

unsigned char min(unsigned char v1, unsigned char v2, unsigned char v3)
{
    if (v1 < v2)
        return v1 < v3 ? v1 : v3;
    return v2 < v3 ? v2 : v3;
}

float calculateLightness(unsigned char r, unsigned char g, unsigned char b)
{
    unsigned char maxValue = max(r, g, b);
    unsigned char minValue = min(r, g, b);
    return (maxValue + minValue) / 2.0;
}

extern "C" {
    void dither(unsigned char* pixels, int imageWidth, int imageHeight, float* errorsBuffer)
    {
        // buffer on either side of error array to avoid bounds checking
        // const errorArrayLength = imageWidth + 4;
        // float[] errorRow1 = errorsBuffer[0 .. errorArrayLength];
        // float[] errorRow2 = errorsBuffer[errorArrayLength .. 2 * errorArrayLength];
        // float[] errorRow3 = errorsBuffer[2 * errorArrayLength .. 3 * errorArrayLength];

        size_t pixelIndex = 0;
        for (int y=0;y<imageHeight;y++)
        {
            // int errorIndex = 2;
            
            for(int x=0;x<imageWidth;x++,pixelIndex+=4)
            {
                // float storedError = errorRow1[errorIndex];
                float lightness = calculateLightness(pixels[pixelIndex], pixels[pixelIndex+1], pixels[pixelIndex+2]);
                // float adjustedLightness = storedError + lightness;
                unsigned char outputValue = lightness > 127 ? 255 : 0;

                //set color in pixels
                pixels[pixelIndex] = outputValue;
                pixels[pixelIndex+1] = outputValue;
                pixels[pixelIndex+2] = outputValue;

                // save error
                // const errorFraction = (adjustedLightness - outputValue) / 42.0;
                // const errorFraction2 = errorFraction * 2;
                // const errorFraction4 = errorFraction * 4;
                // const errorFraction8 = errorFraction * 8;

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

                // errorIndex++;
            }

            // errorRow1[0 .. errorRow1.length] = 0.0;
            
            // float[] temp = errorRow1;
            // errorRow1 = errorRow2;
            // errorRow2 = errorRow3;
            // errorRow3 = temp;
        }
    }
}
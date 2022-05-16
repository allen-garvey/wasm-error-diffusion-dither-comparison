#include <cstddef>
#include <cstdint>
#include <algorithm>

float calculateLightness(uint8_t r, uint8_t g, uint8_t b) {
    uint8_t maxValue = std::max({r, g, b});
    uint8_t minValue = std::min({r, g, b});
    return (maxValue + minValue) / 2.0;
}

extern "C" {
    void dither(uint8_t* pixels, int imageWidth, int imageHeight, float* errorsBuffer) {
        // buffer on either side of error array to avoid bounds checking
        int errorArrayLength = imageWidth + 4;
        float* errorRow1 = errorsBuffer;
        float* errorRow2 = errorsBuffer + errorArrayLength;
        float* errorRow3 = errorsBuffer + 2 * errorArrayLength;

        std::size_t pixelIndex = 0;
        for (int y=0;y<imageHeight;y++){
            int errorIndex = 2;
            
            for(int x=0;x<imageWidth;x++,pixelIndex+=4){
                float storedError = errorRow1[errorIndex];
                float lightness = calculateLightness(pixels[pixelIndex], pixels[pixelIndex+1], pixels[pixelIndex+2]);
                float adjustedLightness = storedError + lightness;
                uint8_t outputValue = adjustedLightness > 127 ? 255 : 0;

                //set color in pixels
                pixels[pixelIndex] = outputValue;
                pixels[pixelIndex+1] = outputValue;
                pixels[pixelIndex+2] = outputValue;

                // save error
                float errorFraction = (adjustedLightness - outputValue) / 42.0;
                float errorFraction2 = errorFraction * 2;
                float errorFraction4 = errorFraction * 4;
                float errorFraction8 = errorFraction * 8;

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

                errorIndex++;
            }

            for(int i=0;i<errorArrayLength;i++){
                errorRow1[i] = 0;
            }
            
            float* temp = errorRow1;
            errorRow1 = errorRow2;
            errorRow2 = errorRow3;
            errorRow3 = temp;
        }
    }
}
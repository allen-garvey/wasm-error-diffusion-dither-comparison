import messageHeaders from '../message-headers';
import { dither } from '../dither/dither';

let pixels =        null;
let imageHeight =   0;
let imageWidth =    0;

onmessage = event => {
    const data = event.data;

    switch(data.type){
        case messageHeaders.IMAGE_LOAD:
            pixels = data.pixels;
            imageHeight = data.height;
            imageWidth = data.width;
            break;
        case messageHeaders.DITHER_JS:
            const ditherJsResults = dither(pixels, imageWidth, imageHeight);
            postMessage({
                type: messageHeaders.DITHER_RESULTS,
                ...ditherJsResults,
            }, [ditherJsResults.pixels.buffer]);
            break;
    }
};

postMessage({
    type: messageHeaders.WORKER_READY,
});
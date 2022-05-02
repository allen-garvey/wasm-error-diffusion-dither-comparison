import messageHeaders from '../message-headers';
import { dither } from './dither';
import { ditherWasm } from './ditherWasm';
import wasm from './wasm';

let pixels =        null;
let imageHeight =   0;
let imageWidth =    0;
const wasmDithers = {};

onmessage = event => {
    const data = event.data;

    switch(data.type){
        case messageHeaders.IMAGE_LOAD:
            pixels = data.pixels;
            imageHeight = data.height;
            imageWidth = data.width;
            wasm.instantiate(wasmDithers, imageWidth, imageHeight).then(() => {
                postMessage({
                    type: messageHeaders.WORKER_IMAGE_LOADED,
                });
            });
            break;
        case messageHeaders.DITHER_JS:
            const ditherJsResults = dither(pixels, imageWidth, imageHeight);
            postMessage({
                type: messageHeaders.DITHER_RESULTS,
                language: data.type,
                ...ditherJsResults,
            }, [ditherJsResults.pixels.buffer]);
            break;
        case messageHeaders.DITHER_D:
            const ditherWasmResults = ditherWasm(wasmDithers[data.type].instance.exports, pixels, imageWidth, imageHeight);
            postMessage({
                type: messageHeaders.DITHER_RESULTS,
                language: data.type,
                ...ditherWasmResults,
            }, [ditherWasmResults.pixels.buffer]);
            break;
    }
};

wasm.initialize(wasmDithers).then(() => {
    postMessage({
        type: messageHeaders.WORKER_READY,
    });
});
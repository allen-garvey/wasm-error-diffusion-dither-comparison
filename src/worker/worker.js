import messageHeaders from '../message-headers';

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
    }
};

postMessage({
    type: messageHeaders.WORKER_READY,
});
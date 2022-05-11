import messageHeaders from '../message-headers';

const wasmModel = [
    {
        key: messageHeaders.DITHER_D,
        source: 'd',
    },
    {
        key: messageHeaders.DITHER_ZIG,
        source: 'zig',
    },
];

const initializeWasm = (memo) => Promise.all(wasmModel.map(({key, source}) =>
    WebAssembly.compileStreaming(fetch(`/assets/${source}.wasm`))
        .then(module => {
            memo[key] = {
                module,
            };
        })
));

const instantiateWasm = (memo, imageWidth, imageHeight) => {
    const PAGE_SIZE_IN_BYTES = 64 * 1024;
    const imageSizeInPages = Math.ceil(imageWidth * imageHeight * 4 / PAGE_SIZE_IN_BYTES);
    // enough space to store 3 rows of 4 byte floats, with 2 item buffer on each side
    const NUM_ERROR_ROWS = 3;
    const ERROR_ARRAY_ITEM_BYTE_SIZE = 4; //float32
    const errorBufferSizeInPages = Math.ceil((imageWidth + 4) * ERROR_ARRAY_ITEM_BYTE_SIZE * NUM_ERROR_ROWS / PAGE_SIZE_IN_BYTES);
    const memoryPagesRequired = imageSizeInPages + errorBufferSizeInPages;
    
    return Promise.all(Object.keys(memo).map((key) => {
        const model = memo[key];

        return WebAssembly.instantiate(model.module, {})
            .then((instance) => {
                model.instance = instance;
                instance.exports.memory.grow(memoryPagesRequired);
            });
    }));
};

export default {
    initialize:initializeWasm,
    instantiate: instantiateWasm,
};

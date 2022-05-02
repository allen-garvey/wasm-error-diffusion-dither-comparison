import messageHeaders from '../message-headers';

const wasmModel = [
    {
        key: messageHeaders.DITHER_D,
        source: 'd',
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

const instantiateWasm = (memo) => Promise.all(Object.keys(memo).map((key) => {
    const model = memo[key];

    return WebAssembly.instantiate(model.module, {})
        .then((instance) => {
            model.instance = instance;
        });
}));

export default {
    initialize:initializeWasm,
    instantiate: instantiateWasm,
};

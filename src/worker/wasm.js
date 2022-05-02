import messageHeaders from '../message-headers';

const initializeWasm = (memo) => Promise.all([
    {
        key: messageHeaders.DITHER_D,
        source: 'd',
    },
].map(({key, source}) =>
    WebAssembly.instantiateStreaming(fetch(`/assets/${source}.wasm`), {})
        .then(obj => {
            memo[key] = obj.instance.exports.dither;
        })
));

export default {
    initialize:initializeWasm,
};

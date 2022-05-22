FROM ubuntu:22.04
RUN apt update && apt install \
    nodejs \ 
    npm

# create download directory
RUN mkdir -p $HOME/downloads

# install D (ldc2)
RUN curl -s -L https://github.com/ldc-developers/ldc/releases/download/v1.29.0/ldc2-1.29.0-linux-x86_64.tar.xz > $HOME/downloads/ldc2
RUN tar -xf $HOME/downloads/ldc2 -C $HOME && rm $HOME/downloads/ldc2
RUN mv /root/ldc2-1.29.0-linux-x86_64/bin/ldc2 /usr/local/bin

# install C++ (emscripten)
RUN curl -s -L https://github.com/emscripten-core/emsdk/archive/refs/tags/3.1.10.tar.gz > $HOME/downloads/emcc
RUN tar -xf $HOME/downloads/emcc -C $HOME && rm $HOME/downloads/emcc
RUN ls $HOME
RUN $HOME/emsdk-3.1.10/emsdk install latest
RUN mv /root/emsdk-3.1.10/emsdk/upstream/emscripten/emcc /usr/local/bin

# install Rust & wasm-pack
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# install zig
RUN curl -s -L https://ziglang.org/download/0.9.1/zig-linux-x86_64-0.9.1.tar.xz > $HOME/downloads/zig
RUN tar -xf $HOME/downloads/zig -C $HOME
RUN mv /root/zig-linux-x86_64-0.9.1/zig /usr/local/bin

# compile wasm
RUN mkdir -p ./wasm-dither/wasm
WORKDIR ./wasm-dither
ADD wasm ./wasm
ADD makefile .
RUN make

# install npm dependencies
ADD package.json .
ADD package-lock.json .
RUN npm install

# add js / sass files
RUN mkdir sass && mkdir src
ADD sass ./sass
ADD src ./src
ADD webpack.config.js .

# expose server port
EXPOSE 3000

CMD ["npm", "start"]
const wasmPath = new URL('./chip8.wasm', import.meta.url);

export async function init({ print = console.log } = {}) {
    const imports = {
        env: {
            print: (num) => print(num),
        },
    };

    const response = await fetch(wasmPath);
    const bytes = await response.arrayBuffer();
    const { instance } = await WebAssembly.instantiate(bytes, imports);

    return instance.exports;
}

const wasmPath = new URL('./bin/chip8.wasm', import.meta.url);

export async function init() {
    const response = await fetch(wasmPath);
    const bytes = await response.arrayBuffer();
    const { instance } = await WebAssembly.instantiate(bytes);

    const {
        memory,
        disassemble_ptr,
        disassemble_len,
        malloc,
        free,
    } = instance.exports;

    return {
        disassemble: (bytes) => {
            const inPtr = malloc(bytes.length);
            if (inPtr === 0) throw new Error("malloc failed in wasm");

            const inputBytes = new Uint8Array(memory.buffer, inPtr, bytes.length);
            inputBytes.set(bytes);

            const outPtr = disassemble_ptr(inPtr, bytes.length);
            const outLen = disassemble_len();
            if (outPtr === 0) throw new Error("disassemble failed");

            const outputBytes = new Uint8Array(memory.buffer, outPtr, outLen);
            const text = new TextDecoder().decode(outputBytes);

            free(inPtr, bytes.length);
            free(outPtr, outLen);

            return text;
        }
    };
}

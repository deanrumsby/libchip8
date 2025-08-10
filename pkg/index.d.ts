export interface Chip8Wasm {
    disassemble(bytes: UInt8Array): string
}

export function init(): Promise<Chip8Wasm>
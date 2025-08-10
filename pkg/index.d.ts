export interface Chip8Wasm {
    add(a: number, b: number): void
}

export function init(): Promise<Chip8Wasm>
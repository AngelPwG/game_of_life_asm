# Conway's Game of Life in x86-64 Assembly

<p align="center">
  <img src="./assets/anime_girl_asm.png" width="900">
</p>

> Conway's Game of Life implemented from scratch in x86-64 Assembly,
> rendered directly in the terminal using Linux syscalls.

**No C runtime. No ncurses. No graphics library.**

Just Assembly, memory, syscalls and larping.

> This project is still in progress.

<p align="center">
  ──────────────[ x86-64 ]──────────────
</p>

I started this project after working with WASM because I wanted to go even lower and get a better understanding of how the programs interact with memory, registers and the operating system.

The goal is to implement Conway's Game of Life completely in Assembly and run it directly in the Linux terminal.

<p align="center">
  ──────────────[ CURRENT STATE ]──────────────
</p>

## Current state

The program currently:

- stores the board as a 16x16 byte grid
- keeps a second grid as a snapshot of the previous generation
- counts the neighbors of every cell
- applies Conway's Game of Life rules
- prints living cells as `#`
- prints dead cells as `.`
- renders directly to stdout using the `write` syscall
- moves the terminal cursor back to the beginning between generations
- waits between generations using the `nanosleep` syscall

The simulation is already running with a single hardcoded glider, the project is not finished yet.

<p align="center">
  ──────────────[ SYSCALLS ]──────────────
</p>

## Why in x86-64 Assembly

There is no:
- `printf`
- `sleep`
- standard library

Printing one character means doing this every time:

```asm
mov rax, 1
mov rdi, 1
mov rsi, r15
mov rdx, 1
syscall
```

Waiting between each generation means:

```asm
mov rax, 35
lea rdi, [delay]
xor rsi, rsi
syscall
```

And exiting the program means:

```asm
xor rdi, rdi
mov rax, 60
syscall
```

Could this be easier in C?

Of course, but how can I larp with that.

<p align="center">
  ──────────────[ MEMORY ]──────────────
</p>

## Memory

The simulation uses two 256-byte grids:

```text
grid
┌───────────────────────┐
│ current generation    │
│ 16 x 16 cells         │
│ 256 bytes             │
└───────────────────────┘

            copy
              │
              ▼

grid_ss
┌───────────────────────┐
│ generation snapshot   │
│ used while counting   │
│ neighbors             │
└───────────────────────┘
```

Each cell is represented by one byte:

0x00 -> dead
0x01 -> alive

The snapshot allows every cell to evaluate the same generation while the next state is being written.

<p align="center">
  ──────────────[ B3 / S23 ]──────────────
</p>

## Conway's rules

For every cell, the program counts its eight possible neighbors.

```text
┌───┬───┬───┐
│ 1 │ 2 │ 3 │
├───┼───┼───┤
│ 4 │ X │ 5 │
├───┼───┼───┤
│ 6 │ 7 │ 8 │
└───┴───┴───┘
```

A living cell:

- survives with 2 or 3 neighbors
- dies otherwise

A dead cell:

- becomes alive with exactly 3 neighbors

<p align="center">
  ──────────────[ AS -> LD -> ELF ]──────────────
</p>

## Building

```bash
as game_of_life.s -o game_of_life.o
ld game_of_life.o -o game_of_life
./game_of_life
```

<p align="center">
  ──────────────[ TODO ]──────────────
</p>

## Next steps

As you can see the project is not finished yet. I would like to add a way to enter your own cells and then start the simulation, as well as make the grid size variable.
Besides features, I would also like to make the code more efficient or more idiomatic for the language, because I am learning and figuring out how to do things while doing this project.

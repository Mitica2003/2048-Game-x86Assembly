# 2048-Game-x86Assembly

This is an implementation of the popular **2048** game in **x86 Assembly**. The game features a grid where players combine numbered tiles to reach the target tile of **2048**.

## How to Play

1. The game starts with two tiles placed on the 4x4 grid, each having the value of **2**.
2. The player can use arrow keys to move the tiles:
   - **Up, Down, Left, Right** to slide the tiles in respective directions.
3. Tiles with the same number merge into one when they collide, doubling their value.
4. The game ends when the player either reaches **2048** or cannot make any more moves.

## Features

- **4x4 grid** for tile placement.
- Tiles **combine** when they collide with each other.
- Movement is based on **arrow key input**.
- The game ends when **2048** is reached or no more moves can be made.

## Requirements

- **x86 Architecture**
- **Assembler** (NASM or similar assembler)
- **Emulator** (e.g., DOSBox or similar for running the assembly code)

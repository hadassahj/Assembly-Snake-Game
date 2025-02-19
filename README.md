# Snake Game in Assembly (EMU8086)

This is a simple **Snake Game** implemented in **x86 Assembly** for **EMU8086**. The game runs in text mode and features a classic snake gameplay where the player collects food (`@`) while avoiding walls, obstacles (`#`) and self-collisions.

## 🕹️ Controls

- **Arrow Keys**: Move the snake in the desired direction.
  - ⬆️ **Up** - Move the snake upwards.
  - ⬇️ **Down** - Move the snake downwards.
  - ⬅️ **Left** - Move the snake left.
  - ➡️ **Right** - Move the snake right.
- **ESC**: Exit the game.

## 🎯 Objective

- Collect as much food (`@`) as possible.
- Each food item increases your score.
- Avoid crashing into the **walls (`#`)** and **your own body**.

## 🛠️ Features

- **Border Collision Detection**: The snake dies when hitting the walls.
- **Self-Collision Detection**: The snake dies when colliding with itself.
- **Score Counter**: Tracks the number of food items collected.
- **Real-Time Keyboard Input**: Snake movement updates based on keypresses.

## 🔧 Requirements

- **EMU8086** (or any other 16-bit x86 emulator)
- **DOSBox** (optional, for running in a DOS-like environment)

## ▶️ How to Run

1. Open **EMU8086**.
2. Load the `snake.asm` file.
3. Assemble and run the program.
4. Follow the on-screen instructions.

## 📜 Code Structure

The main sections of the code:

- **Game Initialization**: Sets up the text mode and instructions screen.
- **Main Game Loop**: Handles movement, collision detection, and rendering.
- **Input Handling**: Reads keyboard input and updates direction.
- **Collision Detection**: Checks for wall, self, and food collisions.
- **Border Drawing**: Creates the playing field boundaries.
- **Game Over Routine**: Displays the final score when the game ends.

## 🖥️ Screenshot (Example)

![Screenshot 2025-01-14 131333](https://github.com/user-attachments/assets/e3d87687-b4dd-4473-ae65-98eac504315d)
![Screenshot 2025-01-14 131446](https://github.com/user-attachments/assets/dc80622d-59c5-47a2-8910-343cb5110902)
![Screenshot 2025-01-14 131529](https://github.com/user-attachments/assets/0734466e-b904-46f7-8859-ca17596dbe29)



# 🧮 Basic Calculator

A macOS calculator made with a SwiftUI client and a Python (FastAPI) backend on `localhost`.

## What it does

- **Operation mode:** add, subtract, multiply, divide, power (`^`), square root (`√`), and percentage (`%`).
- **Algorithm mode UI:** build multi-step algorithms, run them, save by name, run saved algorithms, delete a save, and clear all saves.
- **Step list behavior:** only the last 5 steps are shown in the UI (full step list is still sent for run/save).
- **Error handling:** backend error messages are shown in the UI and prefixed with `Error:`.

## ⚙️ Mathematical Operations 

| Operation Key | Expression | Logic & Edge Case Handling |
| :--- | :--- | :--- |
| **`addition`** | n1 + n2 | Sums two numbers. |
| **`subtraction`** | n1 - n2 | Subtracts the second number from the first. |
| **`multiplication`** | n1 * n2 | Multiplies two numbers. |
| **`division`** | n1 / n2 | Divides n1 by n2 |
| **`power`** | n1^n2 | Gives n2 power of n1 |
| **`square_root`** | √n1 | Gives n1's square root |
| **`percentage`** | (n1 * n2) / 100 | Calculates n2 percent of n1. |

## ⚙️ Algorithm Mode Operations

| Action Key | Description | Requirements |
| :--- | :--- | :--- |
| **`save`** | Saves the algorithm steps to the JSON file | `alg_save_name`, `steps` |
| **`run`** | Executes the provided steps immediately | `steps`, `x` |
| **`run_save`** | Loads and runs a saved algorithm by name | `alg_save_name`, `x` |
| **`delete`** | Removes a specific saved algorithm | `alg_save_name` |
| **`clear_all`** | Wipes all saved algorithms from the file | None |

## Requirements

- **macOS** with Swift toolchain.
- **Python 3** with **FastAPI**,**Uvicorn** and **aiofiles**.

Install Python dependencies:

```bash
pip install fastapi uvicorn aiofiles
```
## Run

1. Start backend:

```bash
python server.py
```

2. Build and run app (in project root):

```bash
swiftc -parse-as-library main.swift ContentView.swift -o CalcApp && ./CalcApp
```

Backend default URL is `http://127.0.0.1:54823/receive_data`.

 

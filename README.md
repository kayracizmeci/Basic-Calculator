# 🧮 Basic Calculator

A macOS calculator made with a SwiftUI client and a Python (FastAPI) backend on `localhost`.

## What it does

- **Operation mode:** add, subtract, multiply, divide, power (`^`), square root (`√`), and percentage (`%`).
- **Algorithm mode UI:** build multi-step algorithms, run them, save by name, run saved algorithms, delete a save, and clear all saves.
- **Step list behavior:** only the last 5 steps are shown in the UI (full step list is still sent for run/save).
- **Error handling:** backend error messages are shown in the UI and prefixed with `Error:`.

## Requirements

- **macOS** with Swift toolchain.
- **Python 3** with **FastAPI** and **Uvicorn**.

Install Python dependencies:

```bash
pip install fastapi uvicorn
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

 

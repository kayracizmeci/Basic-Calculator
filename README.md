# 🧮 Basic Calculator

A macOS calculator made of a SwiftUI app and a small Python (FastAPI) server on your machine. You enter two numbers, tap an operation, and the server returns the result over HTTP on `localhost`.

## What it does

- **Basic math:** add, subtract, multiply, divide, power (`^`), square root (`√`), and percentage (`%`) using your two inputs.
- **Optional “algorithm” API:** the server can save named step sequences to `algorithm.json`, run them on a value, delete saves, or clear all (this feature will be added in the future to the UI).

## Requirements

- **macOS** with Xcode / Swift toolchain (to build and run the SwiftUI client).
- **Python 3** with **FastAPI** and **Uvicorn** (`pip install fastapi uvicorn`).
- Start `**python server.py`** before using the app (default: `http://127.0.0.1:54823` — set `PORT` if you change it and update the URL in `ContentView.swift`).

 

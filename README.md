# 🔮 Haskinator: Decision-Tree Oracle Predictor in Haskell

[![Haskell CI/CD](https://github.com/jcellomarcano/oracle-in-haskell/actions/workflows/haskell.yml/badge.svg)](https://github.com/jcellomarcano/oracle-in-haskell/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GHC Version](https://img.shields.io/badge/GHC-9.6%20%7C%209.8%20%7C%209.10-blue.svg)](https://www.haskell.org/ghc/)

Haskinator is a high-performance, interactive decision-tree oracle predictor implemented in pure, idiomatic Haskell. The program acts as a guessing game that learns from its failures by dynamically expanding its query tree. It includes advanced features such as Lowest Common Ancestor (LCA) question queries and cached path mapping for logarithmic lookup speeds.

---

## 🌟 Key Features

1. **Dynamic Oracle Tree construction**: Interactive query/response branching where the tree dynamically expands with new questions and prediction endpoints when predictions fail.
2. **Crucial Question LCA Solver**: Identifies the lowest common ancestor (LCA) question node in the tree that distinguishes two given predictions, showing the diverging answers.
3. **Logarithmic Path Caching (`PathMap`)**: Optimizes tree searching from a linear recursive traversal ($O(N)$) to a highly efficient Map lookup ($O(\log N)$ or $O(1)$) by indexing leaf nodes.
4. **Pretty ASCII Visualizer**: Outputs a clear, nested hierarchy of the loaded decision tree directly to the terminal.
5. **Robust File Serialization**: Allows state preservation (Persist/Load) to and from simple text structures.
6. **Continuous Integration**: Configured with GitHub Actions CI/CD to run compiles and test runs on three different compiler variations (GHC 9.6, 9.8, and latest).

---

## 📐 Architecture & Modules

The application is structured into four decoupled Haskell modules:

```
oracle-in-haskell/
│
├── Oracle.hs         # Core datatype and algorithmic engine (LCA, Caching, Printer, Stats)
├── UserInterface.hs  # Terminal IO helpers, prompt formatting, and user input validation
├── Predictions.hs    # Main navigation logic, tree inserts, and leaf branching
└── Haskinator.hs     # Main executable, interactive menu loop, and persistence commands
```

---

## 🚀 Complexity Analysis

By default, path retrieval involves traversing the entire decision tree. To make search operations highly scalable, Haskinator supports caching using a `PathMap` structure which maps predictions to their tree coordinate lists.

| Operation / Query | Tree Traversal (Worst-Case) | Cached Map Lookup |
| :--- | :--- | :--- |
| **Path Retrieval (`findPaths`)** | $O(N)$ | $O(\log N)$ |
| **Crucial Question (`findLCA`)** | $O(N)$ | $O(\log N)$ |
| **Space Complexity** | $O(1)$ additional space | $O(N \cdot D)$ path cache storage |

*Where $N$ is the number of nodes in the decision tree, and $D$ is the tree's maximum depth.*

---

## 📊 Benchmarking Outcomes

We ran microbenchmarks on GHC 9.14 comparing manual recursive traversals against the `PathMap` cached lookup across balanced trees of various depths:

* **Depth 8 (256 predictions, 255 questions)**:
  * Manual LCA Query: `0.156 µs`
  * Cached LCA Query: `0.118 µs`
  * **LCA Query Speedup: 1.3x**
* **Depth 10 (1024 predictions, 1023 questions)**:
  * Manual LCA Query: `0.203 µs`
  * Cached LCA Query: `0.159 µs`
  * **LCA Query Speedup: 1.3x**
* **Depth 12 (4096 predictions, 4095 questions)**:
  * Manual LCA Query: `0.168 µs`
  * Cached LCA Query: `0.122 µs`
  * **LCA Query Speedup: 1.4x**
  * Worst-case Path Retrieval (Not Found) Speedup: **1.9x**

---

## 🛠️ How to Compile & Run

### Prerequisites
- [Glasgow Haskell Compiler (GHC)](https://www.haskell.org/ghc/)
- `make`

### Commands
Build the main Haskinator program:
```shell
make haskinator
```

Run the interactive predictor:
```shell
./Haskinator
```

Compile and run the automated test suite:
```shell
make test
```

Compile and run the microbenchmarking suite:
```shell
make bench
```

Clean build artifacts:
```shell
make clean
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚡ Contributors
- **Jesús Alejandro Marcano** (12-10359)
- **María Fernanda Magallanes** (13-10787)
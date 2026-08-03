# 3D_mec Workspace

This repository provides a unified workspace for configuring, building, and running multibody 3D mechanical simulations using the **`lib_3d_mec_ginac`** (C++ core engine) and **`pylib3d-mec-ginac`** (Python Cython bindings) libraries.

---

## 🏛️ Architecture Overview

* **[lib_3d_mec_ginac](https://github.com/aitorplaza/lib_3d_mec_ginac)**: Core library written in C++ that performs symbolic kinematics and dynamics calculations using **GiNaC** and **CLN**.
* **[pylib3d-mec-ginac](https://github.com/aitorplaza/pylib3d-mec-ginac)**: Python package wrapping the C++ core via Cython, enabling Python scripts to run 3D mechanism simulations seamlessly.

---

## 🛠️ Prerequisites

Before installing the workspace, ensure your Linux system (Ubuntu/Debian) has the required build tools and mathematical libraries installed:

```bash
sudo apt update && sudo apt install -y \
    build-essential \
    pkg-config \
    cmake \
    libgsl-dev \
    libblas-dev \
    liblapack-dev \
    libcln-dev \
    libginac-dev \
    libgl1-mesa-dev \
    python3-venv \
    python3-dev
```

---

## 🚀 Quick Start (Installation)

Clone this workspace repository and run the setup script:

```bash
git clone https://github.com/aitorplaza/3D_mec_workspace.git
cd 3D_mec_workspace
./setup_workspace.sh
```

### What `setup_workspace.sh` does automatically:
1. Verifies system dependencies (`cmake`, `g++`, `libgsl-dev`, `GiNaC`, `CLN`, etc.) and offers to install missing ones via `apt`.
2. Clones `lib_3d_mec_ginac` and `pylib3d-mec-ginac` if they are not already present.
3. Compiles and installs the C++ core library locally.
4. Sets up a Python virtual environment (`venv`) with all required Python dependencies.
5. Synchronizes C++ headers and shared libraries (`.so`) with the Python bindings package.
6. Compiles Cython wrappers and installs `pylib3d-mec-ginac` inside the virtual environment.

---

## 💻 Usage & Running Examples

1. **Activate the virtual environment**:
   ```bash
   source venv/bin/activate
   ```

2. **Run an example simulation**:
   ```bash
   cd examples
   python 4bar.py
   ```

---

## 🔄 Development Workflow

When modifying code within the workspace, follow these guidelines:

### Updating C++ Core Logic (`lib_3d_mec_ginac`)
If you make changes to C++ source files or headers in `lib_3d_mec_ginac/`, update the entire workspace by running:

```bash
./update_libraries.sh
```

This script automatically:
* Re-compiles and installs the C++ core library.
* Syncs updated binaries (`.so`) and headers into `pylib3d-mec-ginac`.
* Re-compiles and re-installs the Python bindings.

### Building Distributable Python Wheels
To build a standalone `.whl` wheel for distribution:

```bash
./build_wheel.sh
```

---

## 📁 Repository Structure

```text
3D_mec_workspace/
├── setup_workspace.sh     # Master installer & bootstrapper
├── update_libraries.sh    # Sync & rebuild workflow script
├── build_wheel.sh         # Distributable package builder
├── lib_3d_mec_ginac/      # C++ Core Mechanical Engine (git submodule/repo)
├── pylib3d-mec-ginac/     # Python Cython Bindings (git submodule/repo)
├── examples/              # Simulation examples and models
└── venv/                  # Python Virtual Environment (generated)
```


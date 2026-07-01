# 3D_mec Workspace

This repository contains the helper scripts and examples needed to easily compile and simulate 3D mechanisms using the `lib_3d_mec_ginac` (C++) and `pylib3d-mec-ginac` (Python Cython wrapper) libraries.

## Workspace Contents

* **`examples/`** — Directory containing physical mechanism simulation models (e.g., four-bar linkage).
* **`setup_workspace.sh`** — Master bootstrap script that clones, builds, and sets up the C++ and Python environments.
* **`update_libraries.sh`** — Script to compile C++ source code updates, synchronize headers/libraries, and reinstall Python bindings.
* **`build_wheel.sh`** — Script to package the local Python wrapper into a distributable wheel (`.whl`).

## Quick Start (Installation)

To set up the workspace, simply run the master installer script:

```bash
./setup_workspace.sh
```

During execution, the script will ask for the path/name of your workspace directory.
* Press **Enter** to install everything directly in the current directory.
* Alternatively, enter a path where you want the directories to be created.

Once completed, follow the on-screen instructions to activate your Python virtual environment and run the examples.

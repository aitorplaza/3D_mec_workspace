#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Resolve script directory (where setup_workspace.sh is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Enter the path/name for the workspace directory."
read -p "Workspace directory [Default: ${SCRIPT_DIR}]: " USER_INPUT

if [ -z "${USER_INPUT}" ]; then
    WORKSPACE_DIR="${SCRIPT_DIR}"
else
    # If path is absolute, use it; otherwise, resolve relative to current pwd
    if [[ "${USER_INPUT}" = /* ]]; then
        WORKSPACE_DIR="${USER_INPUT}"
    else
        WORKSPACE_DIR="$(pwd)/${USER_INPUT}"
    fi
fi

CPP_DIR="${WORKSPACE_DIR}/lib_3d_mec_ginac"
PYTHON_DIR="${WORKSPACE_DIR}/pylib3d-mec-ginac"
VENV_DIR="${WORKSPACE_DIR}/venv"

echo "=========================================================="
echo "    lib_3d_mec_ginac & pylib3d-mec-ginac Setup Script"
echo "=========================================================="
echo ""

# --------------------------------------------------------
# Step 1: Pre-installation checks (System Dependencies)
# --------------------------------------------------------
# Check individual system/pkg-config dependencies
MISSING_PKGS=()

if ! command -v g++ &> /dev/null; then
    MISSING_PKGS+=("build-essential")
fi

if ! command -v pkg-config &> /dev/null; then
    MISSING_PKGS+=("pkg-config")
fi

if ! command -v cmake &> /dev/null; then
    MISSING_PKGS+=("cmake")
fi

if ! pkg-config --exists gsl; then
    MISSING_PKGS+=("libgsl-dev")
fi

if ! pkg-config --exists blas; then
    MISSING_PKGS+=("libblas-dev")
fi

if ! pkg-config --exists lapack; then
    MISSING_PKGS+=("liblapack-dev")
fi

if ! pkg-config --exists cln; then
    MISSING_PKGS+=("libcln-dev")
fi

if ! pkg-config --exists ginac; then
    MISSING_PKGS+=("libginac-dev")
fi

if [ ${#MISSING_PKGS[@]} -ne 0 ]; then
    echo "WARNING: The following required system packages are missing:"
    for pkg in "${MISSING_PKGS[@]}"; do
        echo "  - ${pkg}"
    done
    echo ""
    read -p "Would you like to install the missing packages now using sudo apt? [Y/n] " INSTALL_CHOICE
    INSTALL_CHOICE=${INSTALL_CHOICE:-Y}
    if [[ "${INSTALL_CHOICE}" =~ ^[Yy]$ ]]; then
        echo "Running: sudo apt update && sudo apt install -y ${MISSING_PKGS[*]}"
        sudo apt update && sudo apt install -y "${MISSING_PKGS[@]}"
    else
        echo "ERROR: Missing required packages: ${MISSING_PKGS[*]}"
        echo "Please install them manually using:"
        echo "    sudo apt install -y ${MISSING_PKGS[*]}"
        exit 1
    fi
fi

echo "System dependencies verified successfully!"
echo ""

# --------------------------------------------------------
# Step 2: Create Workspace Directory
# --------------------------------------------------------
echo "--> Step 2: Creating workspace directory: ${WORKSPACE_DIR}..."
mkdir -p "${WORKSPACE_DIR}"
cd "${WORKSPACE_DIR}"

# --------------------------------------------------------
# Step 3: Clone Repositories
# --------------------------------------------------------
echo "--> Step 3: Cloning C++ and Python repositories..."

if [ ! -d "lib_3d_mec_ginac" ]; then
    echo "Cloning C++ library (lib_3d_mec_ginac) default branch..."
    git clone https://github.com/aitorplaza/lib_3d_mec_ginac
else
    echo "C++ repository already exists, skipping clone."
fi

if [ ! -d "pylib3d-mec-ginac" ]; then
    echo "Cloning Python bindings (pylib3d-mec-ginac)..."
    git clone https://github.com/aitorplaza/pylib3d-mec-ginac
else
    echo "Python repository already exists, skipping clone."
fi
echo ""

# --------------------------------------------------------
# Step 4: Compile & Install C++ Library
# --------------------------------------------------------
echo "--> Step 4: Configuring and compiling C++ core library..."
cd "${CPP_DIR}"

echo "Running CMake configuration..."
rm -rf build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="${WORKSPACE_DIR}" ..

echo "Compiling C++ source files (this may take a minute)..."
make

echo "Installing C++ library headers and binaries locally..."
make install
echo ""

# --------------------------------------------------------
# Step 5: Setup Python Virtual Environment (venv)
# --------------------------------------------------------
cd "${WORKSPACE_DIR}"
echo "--> Step 5: Creating Python virtual environment in ${VENV_DIR}..."
python3 -m venv venv

echo "Upgrading pip, setuptools, and wheel in virtual environment..."
"${VENV_DIR}/bin/pip" install -U pip setuptools wheel

echo "Installing Python build and run dependencies (Cython, numpy, etc.)..."
"${VENV_DIR}/bin/pip" install Cython numpy asciitree tabulate build
echo ""

# --------------------------------------------------------
# Step 6: Align Binaries & Headers for Portability
# --------------------------------------------------------
echo "--> Step 6: Syncing shared libraries (.so) and C++ headers..."
PY_LIB_DIR="${PYTHON_DIR}/lib/linux/x86_64"

# Copy C++ compiled .so
SO_FILE="${WORKSPACE_DIR}/lib/lib_3d_mec_ginac.so.2.0.0"
if [ ! -f "${SO_FILE}" ]; then
    SO_FILE="${WORKSPACE_DIR}/lib/lib_3d_mec_ginac-2.0-2.0.so.2.0.0"
fi
cp "${SO_FILE}" "${PY_LIB_DIR}/lib_3d_mec_ginac.so"
ln -sf lib_3d_mec_ginac.so "${PY_LIB_DIR}/lib_3d_mec_ginac-2.0-2.0.so.2"
ln -sf lib_3d_mec_ginac.so "${PY_LIB_DIR}/lib_3d_mec_ginac.so.2"

# Copy system dependency libraries
cp -L /usr/lib/x86_64-linux-gnu/libcln.so "${PY_LIB_DIR}/libcln.so"
cp -L /usr/lib/x86_64-linux-gnu/libginac.so "${PY_LIB_DIR}/libginac.so"

# Replace old bundled headers with system headers and newly built C++ headers to avoid ABI mismatch
rm -rf "${PYTHON_DIR}/include/ginac" "${PYTHON_DIR}/include/cln"
cp -r /usr/include/ginac "${PYTHON_DIR}/include/ginac"
cp -r /usr/include/cln "${PYTHON_DIR}/include/cln"
cp -r "${WORKSPACE_DIR}/include/lib_3d_mec_ginac"/* "${PYTHON_DIR}/include/"

echo "Shared libraries and headers synchronized."
echo ""

# --------------------------------------------------------
# Step 7: Rebuild and Install Python Extension
# --------------------------------------------------------
echo "--> Step 7: Compiling Cython wrapper and installing Python package..."
INSTALL_GUI=false "${VENV_DIR}/bin/pip" install --force-reinstall --no-build-isolation "./pylib3d-mec-ginac"
echo ""

# --------------------------------------------------------
# Step 8: Verify Installation
# --------------------------------------------------------
echo "--> Step 8: Verifying Python library import..."
if "${VENV_DIR}/bin/python" -c "import lib3d_mec_ginac; print('Success!')" &> /dev/null; then
    echo "Verification complete: pylib3d-mec-ginac is fully functional!"
else
    echo "ERROR: Verification failed! Could not import the library."
    exit 1
fi
echo ""

echo "=========================================================="
echo "    SETUP COMPLETED SUCCESSFULLY!"
echo "=========================================================="
echo "To get started:"
echo "  1. Activate the environment: source ${WORKSPACE_DIR}/venv/bin/activate"
echo "  2. Test the installation: python examples/test_lib.py "
#echo "  2. Run the four bar example: cd ${TARGET_DIR}/pylib3d-mec-ginac && INSTALL_GUI=false python -m lib3d_mec_ginac examples/four_bar"
echo "=========================================================="

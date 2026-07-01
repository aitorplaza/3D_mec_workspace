#!/usr/bin/env bash

# Salir inmediatamente si algún comando falla
set -e

# Directorios de trabajo (resolución dinámica de ruta)
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_DIR="${WORKSPACE_DIR}/pylib3d-mec-ginac"
VENV_DIR="${WORKSPACE_DIR}/venv"
DIST_DIR="${WORKSPACE_DIR}/dist"

echo "=== 1. Asegurando copias de librerías y cabeceras del sistema ==="
TARGET_DIR="${PYTHON_DIR}/lib/linux/x86_64"

# Asegurar copia de la librería compilada de C++
SO_FILE="${WORKSPACE_DIR}/lib/lib_3d_mec_ginac.so.2.0.0"
if [ ! -f "${SO_FILE}" ]; then
    SO_FILE="${WORKSPACE_DIR}/lib/lib_3d_mec_ginac-2.0-2.0.so.2.0.0"
fi

if [ -f "${SO_FILE}" ]; then
    cp "${SO_FILE}" "${TARGET_DIR}/lib_3d_mec_ginac.so"
    ln -sf lib_3d_mec_ginac.so "${TARGET_DIR}/lib_3d_mec_ginac-2.0-2.0.so.2"
    ln -sf lib_3d_mec_ginac.so "${TARGET_DIR}/lib_3d_mec_ginac.so.2"
else
    echo "Aviso: No se encontró la librería C++ compilada localmente en ${SO_FILE}."
    echo "Se usará el archivo .so existente en ${TARGET_DIR}/lib_3d_mec_ginac.so."
fi

# Asegurar copias del sistema de GiNaC y CLN
cp -L /usr/lib/x86_64-linux-gnu/libcln.so "${TARGET_DIR}/libcln.so"
cp -L /usr/lib/x86_64-linux-gnu/libginac.so "${TARGET_DIR}/libginac.so"

rm -rf "${PYTHON_DIR}/include/ginac" "${PYTHON_DIR}/include/cln"
cp -r /usr/include/ginac "${PYTHON_DIR}/include/ginac"
cp -r /usr/include/cln "${PYTHON_DIR}/include/cln"

echo "=== 2. Creando el archivo Wheel (.whl) ==="
mkdir -p "${DIST_DIR}"

# Construir el Wheel directamente usando pip wheel
INSTALL_GUI=false "${VENV_DIR}/bin/pip" wheel --wheel-dir="${DIST_DIR}" --no-build-isolation "./pylib3d-mec-ginac"

echo ""
echo "=== ¡Wheel generado con éxito en ${DIST_DIR}/! ==="
ls -l "${DIST_DIR}"/*.whl

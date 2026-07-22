#!/usr/bin/env bash

# Salir inmediatamente si algún comando falla
set -e

# Directorios de trabajo
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_DIR="${WORKSPACE_DIR}/lib_3d_mec_ginac"
PYTHON_DIR="${WORKSPACE_DIR}/pylib3d-mec-ginac"
VENV_DIR="${WORKSPACE_DIR}/venv"

echo "=== 1. Compilando la librería de C++ (lib_3d_mec_ginac) ==="
cd "${CPP_DIR}"
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="${WORKSPACE_DIR}" ..
make
make install


echo "=== 2. Copiando el archivo .so generado ==="
SO_FILE="${WORKSPACE_DIR}/lib/lib_3d_mec_ginac.so.2.0.0"
if [ ! -f "${SO_FILE}" ]; then
    SO_FILE="${WORKSPACE_DIR}/lib/lib_3d_mec_ginac-2.0-2.0.so.2.0.0"
fi
TARGET_DIR="${PYTHON_DIR}/lib/linux/x86_64"

cp "${SO_FILE}" "${TARGET_DIR}/lib_3d_mec_ginac.so"
ln -sf lib_3d_mec_ginac.so "${TARGET_DIR}/lib_3d_mec_ginac-2.0-2.0.so.2"
ln -sf lib_3d_mec_ginac.so "${TARGET_DIR}/lib_3d_mec_ginac.so.2"

echo "=== 3. Asegurando copias de librerías del sistema ==="
cp -L /usr/lib/x86_64-linux-gnu/libcln.so "${TARGET_DIR}/libcln.so"
cp -L /usr/lib/x86_64-linux-gnu/libginac.so "${TARGET_DIR}/libginac.so"

echo "=== 3.5. Asegurando cabeceras del sistema actualizadas ==="
rm -rf "${PYTHON_DIR}/include/ginac" "${PYTHON_DIR}/include/cln"
cp -r /usr/include/ginac "${PYTHON_DIR}/include/ginac"
cp -r /usr/include/cln "${PYTHON_DIR}/include/cln"
cp -r "${WORKSPACE_DIR}/include/lib_3d_mec_ginac"/* "${PYTHON_DIR}/include/"


echo "=== 4. Reinstalando la librería de Python en el entorno virtual ==="
cd "${WORKSPACE_DIR}"
INSTALL_GUI=false "${VENV_DIR}/bin/pip" install --force-reinstall --no-build-isolation "./pylib3d-mec-ginac"

echo "=== 5. Verificando la instalación ==="
"${VENV_DIR}/bin/python" -c "import lib3d_mec_ginac; print('¡Librería de Python importada con éxito!')"

echo "=== ¡Proceso completado con éxito! ==="

#!/usr/bin/env bash
set -ex

mkdir build
cd build

# Patch CMakeLists.txt to remove problematic python build/install
$PYTHON -c "import os; content = open('../bindings/python/CMakeLists.txt').read(); content = content.replace('add_custom_target(python ALL', 'add_custom_target(python'); import re; content = re.sub(r'install\(CODE \"execute_process.*prefix=\${CMAKE_INSTALL_PREFIX}\)\)', '', content, flags=re.DOTALL); open('../bindings/python/CMakeLists.txt', 'w').write(content)"

cmake ${CMAKE_ARGS} \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_SBINDIR=bin \
    -DBUILD_PYTHON=ON \
    -DBUILD_CLI=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DENABLE_PACKAGING=OFF \
    -DINSTALL_UDEV_RULES=OFF \
    -DPython_EXECUTABLE:FILEPATH=$PYTHON \
    -DWITH_DOC=OFF \
    ..

cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

# Install python bindings from generated setup.py in build directory
$PYTHON -m pip install . --no-deps --no-build-isolation --ignore-installed -vv

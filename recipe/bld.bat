setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
cd build

:: Patch CMakeLists.txt to remove problematic python build/install
%PYTHON% -c "import os; content = open('../bindings/python/CMakeLists.txt').read(); content = content.replace('add_custom_target(python ALL', 'add_custom_target(python'); import re; content = re.sub(r'install\(CODE \"execute_process.*prefix=\${CMAKE_INSTALL_PREFIX}\)\)', '', content, flags=re.DOTALL); open('../bindings/python/CMakeLists.txt', 'w').write(content)"
if errorlevel 1 exit 1

:: configure
cmake -G "Ninja" %CMAKE_ARGS% ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DCMAKE_CXX_STANDARD=14 ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR:PATH="lib" ^
    -DCMAKE_INSTALL_SBINDIR:PATH="bin" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DLIBUSB_LIBRARIES:PATH="%LIBRARY_LIB%\libusb-1.0.lib" ^
    -DLIBUSB_INCLUDE_DIRS:PATH="%LIBRARY_INC%\libusb-1.0" ^
    -DENABLE_PACKAGING=OFF ^
    -DINSTALL_UDEV_RULES=OFF ^
    -DBUILD_PYTHON=ON ^
    -DBUILD_CLI=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTS=OFF ^
    -DPython_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DWITH_DOC=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Install python bindings from generated setup.py in build directory
%PYTHON% -m pip install . --no-deps --no-build-isolation --ignore-installed -vv
if errorlevel 1 exit 1

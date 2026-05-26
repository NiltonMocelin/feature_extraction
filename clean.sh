rm *.lock
rm src/*
rm -rf __pycache__/

cd tcptrace
make clean
make
cd ..

# compilar api tcptrace:
cd tcptrace_api
rm -rf build/ *.so cython_debug/ __pycache__/
make clean
cd ..

# compilar cython:
cd compilar_cython
rm -rf build/ *.so cython_debug/ __pycache__/
cd ..
echo "Clean!"

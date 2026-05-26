# make clean && make CFLAGS="-fopenmp" LDLIBS="-lgomp -lpthread -lm"
cd /home/nnmoc/traffic_classification02/extrator_cython/tcptrace
make

cd /home/nnmoc/traffic_classification02/extrator_cython/tcptrace_api
python3 setup.py build_ext --inplace
echo "Recomendado miniconda python 3.8 ativo"
sudo apt update && sudo apt install libpcap-dev 

# # miniconda enviromnent python 3.8:
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# bash Miniconda3-latest-Linux-x86_64.sh
# conda create -n py38 python=3.8
# conda activate py38

pip install pypcap cython filelock pyshark numpy pandas matplotlib pymongo

# compilar api tcptrace:
cd tcptrace_python_api
make clean && make
sh compilar.sh
cd ..

# compilar cython:
cd compilar_cython
sh compile.sh
cd ..

echo "Pronto !"


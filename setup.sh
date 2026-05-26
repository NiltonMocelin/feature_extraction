echo "Recomendado miniconda python 3.8 ativo"
# sudo apt update && sudo apt install libpcap-dev 

# # miniconda enviromnent python 3.8:
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# bash Miniconda3-latest-Linux-x86_64.sh
# conda create -n py38 python=3.8
# conda activate py38

# pip install pypcap cython filelock pyshark numpy pandas matplotlib pymongo

sh clean.sh

cd tcptrace
make clean && make
cd ..

# compilar cython:
cd compilar_cython
sh compile.sh
cd ..


# compilar api tcptrace:
cd tcptrace_api
sh compile.sh
cd ..


echo "Pronto !"


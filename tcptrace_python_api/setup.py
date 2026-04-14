from setuptools import setup, Extension
from Cython.Build import cythonize
import os

# 1. Caminho para a pasta raiz do código fonte do tcptrace
TCPTRACE_PATH = "./tcptrace-source" 

# 2. Lista de arquivos objetos (.o) necessários para o tcptrace funcionar
# Você deve incluir os objetos que contêm a lógica de processamento TCP, 
# módulos e a sua nova função ProcessMemoryList.
tcptrace_objects = [
    os.path.join(TCPTRACE_PATH, "tcp.o"),
    os.path.join(TCPTRACE_PATH, "modules.o"),
    os.path.join(TCPTRACE_PATH, "lex.o"),
    # Adicione aqui o arquivo .o onde você colocou a ProcessMemoryList e o MyMemoryReader
    os.path.join(TCPTRACE_PATH, "memory_reader.o") 
]

# 3. Definição da Extensão
ext_modules = [
    Extension(
        name="tcptrace_lib",            # Nome do módulo para importar no Python
        sources=["tcptrace_wrapper.pyx"], # Seu arquivo Cython
        include_dirs=[TCPTRACE_PATH],    # Onde estão os .h do tcptrace
        extra_objects=tcptrace_objects, # Linkagem estática dos objetos C
        # Definições de macro que o tcptrace usa (ajuste conforme seu SO)
        define_macros=[('LINUX', None), ('_REENTRANT', None)],
        extra_compile_args=["-O2", "-w"], # -w suprime warnings do código C antigo
    )
]

setup(
    name="tcptrace_wrapper",
    ext_modules=cythonize(ext_modules, language_level="3"),
)

# python3 setup.py build_ext --inplace

# Teste com:
# import tcptrace_lib
# tcptrace_lib.process_pcap_to_tcptrace("meu_arquivo.pcap")
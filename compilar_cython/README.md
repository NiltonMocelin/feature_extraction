# Compilar cython

## Edite os pyx e pxd se quiser e o setup.py

Para compilar execute:

`python setup.py build_ext --inplace`


# Apos compilar
Isso vai gerar arquivos .so -> sao as bibliotecas especiais cython

Sao diferentes de compilar com gcc g++, mesmo que eles gerem .so tbm

Com os .so do cython, o python sabe importar.

Copie para a pasta ../cython_test/src/*.so

E assim o extrator vai poder usar a biblioteca

Estamos usando o cython_test por enquanto.

# cython debug

compile com: 

`python setup.py build_ext --cython-gdb --inplace
`

agora:

cython --gdb your_module.pyx
# Then compile the generated .c file with a C compiler (like gcc) including debug flags (-g3)
gcc -g3 -Wall -Werror -std=c17 -shared -fPIC -I/usr/local/include/python3.10d your_module.c -o your_module.so

Rode o debuger:

`cygdb . --args python your_main_script.py
`

comandos: 

cy break [module.function] or cy break [line_number]: Sets a breakpoint in the Cython code.
cy step: Steps through Python, Cython, or C code.
cy next: Steps over Python, Cython, or C code.
cy backtrace (or bt): Prints a traceback of relevant frames.
cy print [variable]: Prints the value of a Cython or Python variable.
l (list): Lists the source code around the current